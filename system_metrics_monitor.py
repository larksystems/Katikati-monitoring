import argparse
import datetime
import firebase_admin
import os
import psutil
import sys
import threading
import time

from firebase_admin import credentials, firestore
from core_data_modules.logging import Logger

log = Logger(__name__)
firebase_client = None

DEFAULT_INTERVAL = 600 # wait interval between each set of metric readings in seconds

def init_firebase_client(CRYPTO_TOKEN_PATH):
    log.info("Setting up Firebase client")
    firebase_cred = credentials.Certificate(CRYPTO_TOKEN_PATH)
    firebase_admin.initialize_app(firebase_cred)
    firebase_client = firestore.client()
    log.info("Done")
    return firebase_client

def get_system_metrics():
    metrics = {}

    # record datetime
    metrics['datetime'] = datetime.datetime.now(datetime.timezone.utc).isoformat()

    # current cpu utlization
    cpu_utilization = psutil.cpu_percent(interval=0.1)
    metrics['cpu_percent'] = cpu_utilization

    # cpu load over the last 1, 5 and 15 minutes in percentage
    cpu_load = [round((value / psutil.cpu_count() * 100), 2)
                for value in psutil.getloadavg()]
    metrics['cpu_load_interval_percent'] = dict(
        {
            '1min': cpu_load[0],
            '5min': cpu_load[1],
            '15min': cpu_load[2]
        }
    )

    metrics['memory_usage'] = dict(psutil.virtual_memory()._asdict())

    metrics['disk_usage'] = dict(psutil.disk_usage('/')._asdict())

    log.info("Recorded metrics: {}".format(metrics))
    return metrics


def publish_metrics_to_firestore(metrics):
    try:
        collection_path = 'pipeline_system_metrics'
        firebase_client.collection(collection_path).document(metrics['datetime']).set(metrics)
        log.info("Successfully published metrics to firebase {} collection".format(collection_path))
    except Exception as e:
        log.error(f"Unable to publish metrics due to {e}")

def publish_metrics_to_firestore_multi_systems(metrics):
    try:
        hostname = os.uname()[1].lower()
        collection_path = f"systems/{hostname}/metrics"
        firebase_client.collection(collection_path).document(metrics['datetime']).set(metrics)
        log.info("Successfully published metrics to firebase {} collection".format(collection_path))
    except Exception as e:
        log.error(f"Unable to publish metrics due to {e}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Retrieve system metrics i.e cpu utilization, memory & disk usage')
    parser.add_argument("crypto_token_file",
                        help="path to Firebase crypto token file")
    parser.add_argument("--multi-system", action="store_true",
                        help="whether to store the data in a sub-collection for the current system")

    def _usage_and_exit(error_message):
        print(error_message)
        print()
        parser.print_help()
        exit(1)

    if len(sys.argv) < 2:
        _usage_and_exit("Wrong number of arguments")
    args = parser.parse_args(sys.argv[1:])

    firebase_client = init_firebase_client(args.crypto_token_file)

    while True:
        metrics = get_system_metrics()
        if args.multi_system:
            publish_metrics_to_firestore_multi_systems(metrics)
        else:
            publish_metrics_to_firestore(metrics)
        log.info('Sleeping...')
        time.sleep(DEFAULT_INTERVAL)
