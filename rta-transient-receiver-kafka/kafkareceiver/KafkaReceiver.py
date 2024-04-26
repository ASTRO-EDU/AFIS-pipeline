import json
import argparse
import datetime
import logging
from gcn_kafka import Consumer
import voeventparse as vp
from voeventhandler.voeventhandler import VoeventHandler
from voeventhandler.utilis.loggercfg import configure_logger, get_log_mode, get_log_level
import traceback

logger = None
def removeNotAvailableTopics(subscribeSet, availableVoEventTopics):
    notAvailableTopics = []
    for topic in subscribeSet:
        if topic not in availableVoEventTopics:
            notAvailableTopics.append(topic)
    if len(notAvailableTopics) > 0:
        logger.info("The following topics are not available: ")
        for topic in notAvailableTopics:
            logger.info(topic)
            # remove from subscribeSet to avoid segmentation fault
            subscribeSet.remove(topic)
    return subscribeSet, notAvailableTopics


def main():
    parser = argparse.ArgumentParser(description='Kafka Receiver')
    parser.add_argument('--config-file', type=str, required=True, help='The configuration file')
    parser.add_argument('--log-file', type=str, required=False, help='The path to the output log file')
    args = parser.parse_args()
    print("log file : ",args.log_file)
    print("logger log mode:", get_log_mode())
    configure_logger(log_file=args.log_file, mode=get_log_mode(), level=get_log_level())
    global logger 
    logger = logging.getLogger()
    logger.info(f"configuration file: {args.config_file}")
    logger.info(f"log file: {args.log_file}")
    # read credential from config file
    with open(args.config_file) as f:
        config = json.load(f)
        client_id = config['kafka_client_id']
        client_secret = config['kafka_client_secret']

    logger.debug("Kafka Receiver is starting.")
    # consumer creation
    consumer = Consumer(
                    client_id=client_id,
                    client_secret=client_secret,
                    domain='gcn.nasa.gov'
                )


    subscribeSet = config["topics_to_subscribe"]

    voEventAvailableTopics = sorted([topic for topic in consumer.list_topics().topics if "voevent" in topic])

    # check if the topics to subscribe are available
    subscribeSet, notAvailable = removeNotAvailableTopics(subscribeSet, voEventAvailableTopics)
    logger.debug(f"Connecting to topics: {subscribeSet}")
    logger.error(f"The following topics are not available: {notAvailable}")

    # Subscribe to topics and receive alerts
    consumer.subscribe(subscribeSet)

    # class used to perform action when a voevent is recived
    voeventhandle = VoeventHandler(args.config_file)

    logger.debug(f"Kafka Receiver is started!")

    while True:

        for message in consumer.consume():
            logger.debug(" --------------------------------------------------------------------------------------------- ")
            try:
                inserted, mail_sent, voeventdata, correlations = voeventhandle.handleVoevent(vp.loads(message.value()))
                logger.info(f"Voevent               = {voeventdata}\n") 
                logger.info(f"Saved in the database = {inserted}\n") 
                logger.info(f"Mail sent             = {bool(mail_sent)}\n") 

            except Exception as e:
                trace = traceback.format_exc()
                logger.error(f"Error: {e}\n\n {trace} \n\n{message.value()}")

            finally:
                logger.debug("---------------------------------------------------------------------- \n\n")
            

if __name__ == '__main__':
    main()
