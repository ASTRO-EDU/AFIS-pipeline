## Description

rta-transient-receiver-kafka is a simplified way for handling VoEvents notices provided in xml format by gcn kafka. 

This program extract the data from the xml file, then writes the notices in a MySQL database and performs several processes for detecting a possible correlation among instruments. Then it sends an email alert to the team for further analysis. 


## Installation

### Docker container
please check AFIS-containers repository to create AFIS enviroment:
https://github.com/ASTRO-EDU/AFIS-containers

### Manual installation

Clone the repository:
```
git clone git@github.com:ASTRO-EDU/AFIS-pipeline.git
```
It is recommended to install the dependencies into a virtual enviromnent. For creating a  virtual enviroment: https://docs.python.org/3/library/venv.html
```
python3 -m venv kafka-env
source kafka-env/bin/activate
cd rta-transient-receiver-kafka
./build.sh
```
To run start the deamon use command: 
```
nohup kafkareceiver --config-file /path/to/config.json --log-file /path/to/kafka_receiver.log > /path/to/kafka_receiver_nohup.log 2>&1 &
```

## Configuration file
A configuration file is mandatory to run the software. It contains the credentials to connect
to the database and the Kafka topics, customize the behaviour of the email sender and decides how to handle the test notices. 
The file `rta-transient-receiver/config.template.json` shows the required key-values pairs.

* Section 1: Database
    * `database_user`: the username to connect to the database.
    * `database_password`: the password to connect to the database.
    * `database_host`: the host of the database.
    * `database_port`: the port of the database.
    * `database_name`: the name of the database.
    * `disable_test_notices_seconds`: the number of seconds to wait before processing the test notices.
* Section 2: Email sender
    * `enabled`: if true the email sender is enabled.
    * `packet_with_email_notification`: if true the email sender is enabled for the packet with the given id.
    * `skip_ligo_test`: if true the email sender is disabled for the notices with the ligo test flag.
    * `skip_ste`: if true the email sender is disabled for the notices with the sub-threshold flag (i.e. not-significant for LIGO).
    * `sender_email`: the email address of the sender.    
    * `sender_email_password`: the password of the sender email.  
    * `email_receivers`: the list of the email receivers.
    * `developer_email_receivers`: an email is sent to this list if any runtime exception occurs.
* Section 3: Brokers
    * You can use [this link](https://gcn.nasa.gov/quickstart) for registration and the kafka client credentials generation.
    * `kafka_client_id`: the client id to connect to the Kafka topics.
    * `kafka_client_secret`: the client secret to connect to the Kafka topics.
    * `topics_to_subscribe`: the list of the topics to subscribe.
 

## Run tests
Running LAMP enviroment is suggested to execute tests. rta-transient-receiver-kafka needs a mysql database.
configuration for mysql is available in `rta-transient-receiver-kafka/rta-transient-receiver/voeventhandler/test/conf`. there are several files:
- `create_rt_and_db.sql` and `rt_alert_db_gcn_test_schema.sql` can create the database instance.
- `config.json` contains a configuration instanco for rta-transient-receiver core logic. Check configuration parameters to connect to the database.
to start tests run:

```
cd rta-transient-receiver-kafka
./start_tests.sh
```

## Troubleshooting 
* [Kafka producer FAQs](https://gcn.nasa.gov/docs/faq#what-does-the-warning-subscribed-topic-not-available-gcnclassictextagile_grb_ground-broker-unknown-topic-or-partition-mean)
* Runtime exceptions: If an exception occurrs during the excecution the receiver won't stop running. To check if something went wrong in the output files. 
