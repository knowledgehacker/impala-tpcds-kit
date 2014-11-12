from impala.dbapi import connect
from impala.error import Error
from thrift import Thrift
import re
import time
import sys
import csv
import logging
from joblib import Parallel, delayed
import random

def test_connection():
    conn = connect(host='nuc02', port=21050)
    cur = conn.cursor()

    cur.execute('USE tpcds_1')
    cur.execute('SHOW TABLES')
    print cur.fetchall()


def run_benchmark():
    servers = ['nuc02', 'nuc04', 'nuc05', 'nuc06']
    #sizes = [300, 200, 100, 10, 1]
    sizes = [100]
    streams = 1
    parallelisms = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 30, 40, 50, 100]
    #parallelisms = [6, 7, 8, 9, 10]
    #query_list = [19]
    logging.basicConfig(filename='output/queries.log', level=logging.INFO)
    syntax = 'impala'
    output = 'output/results.csv'
    save_header(output)
    run_queries(servers, sizes, streams, parallelisms, syntax, output)


def save_header(path):
    with open(path, 'wb') as csvfile:
        w = csv.writer(csvfile, delimiter=',')
        w.writerow(['query', 'size', 'stream', 'parallelism', 'measurement'])


def save_results(path, results, size, stream, parallelism):
    with open(path, 'a') as csvfile:
        w = csv.writer(csvfile, delimiter=',')
        for query, measurements in results.iteritems():
            for measurement in measurements:
                w.writerow([query, size, stream, parallelism, measurement])


def run_queries(servers, sizes, streams, parallelisms, syntax, output):
    for stream in range(0,streams):
        for parallelism in parallelisms:
            for size in sizes:
                try:
                    queries = prepare_queries(size, parallelism, syntax)
                    results = Parallel(n_jobs=parallelism)(
                        delayed(run_query_stream)(size, p, parallelism, servers, queries[p]) for p in range(0, parallelism))

                    sys.stdout.write('done\n')
                    i = 0
                    for result in results:
                        save_results(output, result, size, i, parallelism)
                        i += 1
                except:
                    print '\nerror running stream %dGB - stream: %s' % (size, sys.exc_info())


#create a separate query set for each stream
def prepare_queries(size, parallelism, syntax):
    results = {}
    for stream in range(0, parallelism):
        results[stream] = {}
        filename = 'queries/' + str(size) + '/query_' + str(stream % 1) + '.sql'
        with open(filename) as f:
            txt = f.read()
        queries = re.split('-- end query .*', txt)
        for query in queries:
            template = re.search('using template query([0-9]+)\.tpl', query)
            query = re.sub('-- start .*', '', query)
            query = reformat(query, syntax)
            query = re.split(';\n*', query)
            if template is not None:
                nr = 'q' + template.group(1)
                results[stream][nr] = query
    return results


def run_query_stream(size, stream, parallelism, servers, queries):
    sys.stdout.write('\n*** Start %dGB - stream %d/%d ***\n' % (size, stream + 1, parallelism))
    sys.stdout.flush()
    results = {}
    for nr, query in queries.iteritems():
        try:
            server = random.choice(servers)
            conn =  connect(host=server, port=21050)
            cur = conn.cursor()
            db = 'tpcds_' + str(size)
            cur.execute('USE ' + db)
            start = time.time()
            for query_part in query:
                if 'select' in query_part:
                    cur.execute(query_part)

            end = time.time()
            total = end - start
            if not nr in results:
                results[nr] = []
            results[nr].append(total)
            logging.info("%dGB - stream %d/%d - %s: %fs" % (size, stream + 1, parallelism, nr, total))
        except Error as e:
            logging.warn("%dGB - stream %d/%d - %s: failed: %s" % (size, stream + 1, parallelism, nr, str(e)))
        except Thrift.TException as e:
            logging.fatal("%dGB - stream %d/%d - %s: failed: %s" % (size, stream + 1, parallelism, nr, str(e)))
            exit(0)
        finally:
            cur.close()
            conn.close()
        sys.stdout.write('%s:%d.%s ' % (server, stream + 1, nr))
        sys.stdout.flush()

    logging.info("successful queries: [%s]" % ', '.join(key for key, value in results.iteritems()))
    sys.stdout.write('\n*** End %dGB - stream %d/%d *** \n' % (size, stream + 1, parallelism))
    return results


def reformat(query, syntax):
    if syntax is 'impala':
        query = rewrite_returns(query)
        query = rewrite_numeric(query)
        query = rewrite_date_casts(query)
        query = rewrite_string_joins(query)
    return query


#'returns' is a keyword in impala
def rewrite_returns(query):
    return query \
        .replace(' returns', ' returnsimpala') \
        .replace('(returns)', '(returnsimpala)') \
        .replace('coalesce(returns', 'coalesce(returnsimpala')


#impala doesn't like numeric
def rewrite_numeric(query):
    return query.replace('as numeric', 'as decimal').replace('as dec(', 'as decimal(')

#date operations have different syntax in impala
#dates are timestamps
def rewrite_date_casts(query):
    query = re.sub(r'cast\s*\((\'?[0-9a-zA-Z_\-]+\'?)\s+as\s+date\)',
                   r'cast (\1 as timestamp)',
                   query)
    query = re.sub(r'cast\s*\((\'?[0-9a-zA-Z_\-]+\'?)\s+as\s+timestamp\)(\s+([+|\-])\s+([0-9]+)\s+days)',
                   r'date_add(cast(\1 as timestamp), \3\4)',
                   query)
    query = re.sub(r'd1.d_date\s+([+|\-])\s+([0-9]+)',
                   r'date_add(d1.d_date, \1\2)',
                   query)
    return query


def rewrite_string_joins(query):
    #c_last_name || ', ' || c_first_name as customername => concat(c_last_name,', ',c_first_name) as customername
    query = re.sub(
        r'(\'[0-9a-zA-Z_\-\s,]+\'|[a-zA-Z0-9\-_]+)\s*\|\|\s*(\'[0-9a-zA-Z_\-\s,]+\'|[a-zA-Z0-9\-_]+)\s*\|\|\s*(\'[0-9a-zA-Z_\-\s,]+\'|[a-zA-Z0-9\-_]+)\s+as\s+([a-zA-Z0-9\-_]+)',
        r'concat(\1, \2, \3) as \4',
        query)

    #'store' || s_store_id as id => concat('store',s_store_id) as id
    query = re.sub(
        r'(\'[0-9a-zA-Z_\-\s,]+\'|[a-zA-Z0-9\-_]+)\s*\|\|\s*(\'[0-9a-zA-Z_\-\s,]+\'|[a-zA-Z0-9\-_]+)\s+as\s+([a-zA-Z0-9\-_]+)',
        r'concat(\1, \2) as \3',
        query)

    return query


def main():
    run_benchmark()


if __name__ == "__main__":
    main()