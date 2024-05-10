# ************************************************************
# Sequel Pro SQL dump
# Version 4541
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: 127.0.0.1 (MySQL 5.7.44)
# Database: rt_alert_db_gcn_test
# Generation Time: 2025-01-03 11:12:04 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table analysissession
# ------------------------------------------------------------

DROP TABLE IF EXISTS `analysissession`;

CREATE TABLE `analysissession` (
  `analysissessionid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `analysissessiontype_observationid` int(10) unsigned DEFAULT NULL,
  `analysissessiontype_notice_observationid` int(10) unsigned DEFAULT NULL,
  `tstart` double DEFAULT NULL,
  `tstop` double DEFAULT NULL,
  `status` int(11) NOT NULL,
  `diroutputresults` text,
  `pipe_name` varchar(255) DEFAULT NULL,
  `pipe_build` varchar(255) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  PRIMARY KEY (`analysissessionid`),
  UNIQUE KEY `tstart` (`tstart`,`tstop`,`analysissessiontype_observationid`),
  UNIQUE KEY `tstop` (`tstop`,`tstart`,`analysissessiontype_notice_observationid`),
  KEY `analysissession_noticeid` (`analysissessiontype_notice_observationid`),
  KEY `tstart_2` (`analysissessiontype_observationid`),
  CONSTRAINT `analysissession_ibfk_3` FOREIGN KEY (`analysissessiontype_observationid`) REFERENCES `analysissessiontype_observation` (`analysissessiontype_observationid`) ON DELETE CASCADE,
  CONSTRAINT `analysissession_ibfk_4` FOREIGN KEY (`analysissessiontype_notice_observationid`) REFERENCES `analysissessiontype_notice_observation` (`analysissessiontype_notice_observationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`188.15.168.50` */ /*!50003 TRIGGER `analysissession_after_update` BEFORE UPDATE ON `analysissession` FOR EACH ROW trigger_label: BEGIN

			DECLARE postanalysis_id INT UNSIGNED;
            DECLARE postanalysis_type INT;
            DECLARE run_with_no_error INT;
            DECLARE prior_postanalysis_not_ended INT;
            DECLARE analysissession_tstop DOUBLE;

			IF NEW.status != OLD.status AND NEW.status = 1 THEN

				IF NEW.type = 0 THEN 


					
                    SELECT postanalysisid INTO postanalysis_id FROM analysissessiontype_observation ansto JOIN analysissessiontype anst ON (anst.analysissessiontypeid = ansto.analysissessiontypeid) WHERE analysissessiontype_observationid = NEW.analysissessiontype_observationid ;

                    IF postanalysis_id IS NOT NULL THEN



						SELECT tstop INTO analysissession_tstop FROM analysissession WHERE analysissessionid = NEW.analysissessionid;

						
                        SELECT count(*) INTO run_with_no_error FROM run where analysissessionid = NEW.analysissessionid AND status = 5;

                        IF run_with_no_error > 0 THEN

					        
                            SELECT type INTO  postanalysis_type FROM postanalysis WHERE postanalysisid = postanalysis_id;



                            IF postanalysis_type = 0 THEN 

								


								INSERT INTO run (analysissessionid,status,postanalysisid) VALUES (NEW.analysissessionid,2,postanalysis_id);

							ELSEIF postanalysis_type = 1 THEN 

									
                                SELECT count(*) INTO prior_postanalysis_not_ended FROM run r JOIN analysissession ans ON (ans.analysissessionid = r.analysissessionid )  JOIN analysissessiontype_observation ansto ON(ansto.analysissessiontype_observationid = ans.analysissessiontype_observationid) WHERE ansto.analysissessiontype_observationid = NEW.analysissessiontype_observationid AND ans.tstop < analysissession_tstop AND r.status != 5 AND r.status != 6 AND r.status >0;

                                IF prior_postanalysis_not_ended = 0 THEN 

									

									INSERT INTO run (analysissessionid,status,postanalysisid) VALUES (NEW.analysissessionid,2,postanalysis_id);

								ELSE 

                                    

									INSERT INTO run (analysissessionid,status,postanalysisid) VALUES (NEW.analysissessionid,1,postanalysis_id);

                                END IF;


                            END IF;  


                        END IF; 

                    END IF; 


                ELSEIF NEW.type = 1 THEN 

					
                    SELECT postanalysisid INTO postanalysis_id FROM analysissessiontype_notice_observation anstno JOIN analysissessiontype_notice anstn ON(anstn.analysissessiontype_noticeid = anstno.analysissessiontype_noticeid ) JOIN analysissessiontype anst ON (anstn.analysissessiontypeid = anst.analysissessiontypeid) WHERE analysissessiontype_notice_observationid = NEW.analysissessiontype_notice_observationid ;

                    IF postanalysis_id IS NOT NULL THEN

						
                        SELECT count(*) INTO run_with_no_error FROM run where analysissessionid = NEW.analysissessionid AND status = 5;

                        IF run_with_no_error > 0 THEN

							SELECT tstop INTO analysissession_tstop FROM analysissession WHERE analysissessionid = NEW.analysissessionid;

                            
                            SELECT type INTO  postanalysis_type FROM postanalysis WHERE postanalysisid = postanalysis_id;

                            IF postanalysis_type = 0 THEN 

								
								INSERT INTO run (analysissessionid,status,postanalysisid) VALUES (NEW.analysissessionid,2,postanalysis_id);

							ELSEIF postanalysis_type = 1 THEN 


								
                                SELECT count(*) INTO prior_postanalysis_not_ended FROM run r JOIN analysissession ans ON (ans.analysissessionid = r.analysissessionid )  JOIN analysissessiontype_notice_observation anstno ON(anstno.analysissessiontype_notice_observationid = ans.analysissessiontype_notice_observationid) WHERE anstno.analysissessiontype_notice_observationid = NEW.analysissessiontype_notice_observationid AND ans.tstop < analysissession_tstop AND r.status != 5 AND r.status != 6 AND r.status >0;
							                    IF prior_postanalysis_not_ended = 0 THEN 

									

									INSERT INTO run (analysissessionid,status,postanalysisid) VALUES (NEW.analysissessionid,2,postanalysis_id);

								ELSE 

                                    

									INSERT INTO run (analysissessionid,status,postanalysisid) VALUES (NEW.analysissessionid,1,postanalysis_id);

                                END IF;


                            END IF;

                        END IF;

                    END IF;


                END IF;

            END IF;


END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# Dump of table analysissession_sequence
# ------------------------------------------------------------

DROP TABLE IF EXISTS `analysissession_sequence`;

CREATE TABLE `analysissession_sequence` (
  `child_analysissessionid` int(11) unsigned NOT NULL,
  `parent_analysissessionid` int(11) unsigned NOT NULL,
  PRIMARY KEY (`child_analysissessionid`,`parent_analysissessionid`),
  KEY `parent_analysissessionid` (`parent_analysissessionid`),
  CONSTRAINT `analysissession_sequence_ibfk_1` FOREIGN KEY (`child_analysissessionid`) REFERENCES `analysissession` (`analysissessionid`) ON DELETE CASCADE,
  CONSTRAINT `analysissession_sequence_ibfk_2` FOREIGN KEY (`parent_analysissessionid`) REFERENCES `analysissession` (`analysissessionid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table analysissessiontype
# ------------------------------------------------------------

DROP TABLE IF EXISTS `analysissessiontype`;

CREATE TABLE `analysissessiontype` (
  `analysissessiontypeid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL DEFAULT '',
  `shortname` varchar(100) NOT NULL DEFAULT '',
  `aggregation` int(11) NOT NULL,
  `description` text,
  `analysistypeid` int(10) unsigned NOT NULL,
  `analysistriggerid` int(10) unsigned NOT NULL,
  `deltatstart` int(11) NOT NULL,
  `deltatstop` int(11) NOT NULL,
  `timebinsize` double NOT NULL,
  `minbinsize` double NOT NULL,
  `maxbinsize` double NOT NULL,
  `timestep` double NOT NULL,
  `runnable` int(1) NOT NULL,
  `queue` varchar(128) NOT NULL DEFAULT '',
  `reservation` varchar(128) NOT NULL,
  `energybingroupid` int(10) unsigned DEFAULT NULL,
  `skypositiontype` int(1) DEFAULT NULL,
  `skyringgroupid` int(10) unsigned DEFAULT NULL,
  `analysisradius` double DEFAULT NULL,
  `postanalysisid` int(10) unsigned DEFAULT NULL,
  `submit_priority` int(11) NOT NULL,
  PRIMARY KEY (`analysissessiontypeid`),
  UNIQUE KEY `shortname` (`shortname`),
  KEY `energybingroupid` (`energybingroupid`),
  KEY `skyringgroupid` (`skyringgroupid`),
  KEY `analysistriggerid` (`analysistriggerid`),
  KEY `analysistypeid` (`analysistypeid`),
  KEY `postanalysisid` (`postanalysisid`),
  CONSTRAINT `analysissessiontype_ibfk_1` FOREIGN KEY (`postanalysisid`) REFERENCES `postanalysis` (`postanalysisid`),
  CONSTRAINT `analysissessiontypeibfk2` FOREIGN KEY (`energybingroupid`) REFERENCES `energybingroup` (`energybingroupid`) ON DELETE CASCADE,
  CONSTRAINT `analysissessiontypeibfk3` FOREIGN KEY (`skyringgroupid`) REFERENCES `skyringgroup` (`skyringgroupid`) ON DELETE CASCADE,
  CONSTRAINT `analysissessiontypeibfk4` FOREIGN KEY (`analysistriggerid`) REFERENCES `analysistrigger` (`analysistriggerid`) ON DELETE CASCADE,
  CONSTRAINT `analysissessiontypeibfk5` FOREIGN KEY (`analysistypeid`) REFERENCES `analysistype` (`analysistypeid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `analysissessiontype` WRITE;
/*!40000 ALTER TABLE `analysissessiontype` DISABLE KEYS */;

INSERT INTO `analysissessiontype` (`analysissessiontypeid`, `name`, `shortname`, `aggregation`, `description`, `analysistypeid`, `analysistriggerid`, `deltatstart`, `deltatstop`, `timebinsize`, `minbinsize`, `maxbinsize`, `timestep`, `runnable`, `queue`, `reservation`, `energybingroupid`, `skypositiontype`, `skyringgroupid`, `analysisradius`, `postanalysisid`, `submit_priority`)
VALUES
	(1,'Fermi-GBM_MCAL-ALERT','Fermi-GBM_mcal_alert_full',1,NULL,2,2,-1000,1000,2000,2000,0,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(2,'Fermi-GBM_MCAL-ALERT-partial-coverage','Fermi-GBM_mcal_alert_partial',1,NULL,2,2,-1000,1000,2000,0,2000,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(3,'Fermi-GBM-GRB-5s','Fermi-GBM_GRB_5s',1,NULL,4,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(4,'Fermi-GBM-GW-1000s','Fermi-GBM_GW_1000s',1,NULL,6,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(5,'Fermi-GBM-GRB-100s','Fermi-GBM_GRB_100s',1,NULL,4,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(6,'Fermi-GBM-GRB-1000s','Fermi-GBM_GRB_1000s',1,NULL,4,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(7,'Fermi-GBM-visCheckAux','Fermi-GBM-visCheckAux',1,NULL,7,2,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(8,'Fermi-GBM-ratemeters','Fermi-GBM-ratemeters',1,NULL,8,2,-500,500,1000,1000,0,1000,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(9,'Fermi-GBM-ATstatus','Fermi-GBM-ATstatus',1,NULL,9,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(10,'Swift-MCAL-ALERT','Swift_mcal_alert_full',1,NULL,2,3,-1000,1000,2000,2000,0,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(11,'Swift-MCAL-ALERT-partial-coverage','Swift_mcal_alert_partial',1,NULL,2,3,-1000,1000,2000,0,2000,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(12,'Swift-GRB-10s','Swift_GRB_10s',1,NULL,4,3,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(13,'Swift-GW-1000s','Swift_GW_1000s',1,NULL,6,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(14,'Swift-GRB-100s','Swift_GRB_100s',1,NULL,4,3,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(15,'Swift-GRB-1000s','Swift_GRB_1000s',1,NULL,4,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(16,'Swift-visCheckAux','Swift-visCheckAux',1,NULL,7,3,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(17,'Swift-ratemeters','Swift-ratemeters',1,NULL,8,3,-500,500,1000,1000,0,1000,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(18,'Swift-ATstatus','Swift-ATstatus',1,NULL,9,3,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(19,'Fermi-GBM-aitoff-e10-e50000-1000s','Fermi-GBM-aitoff-e10-e50000-1000s',1,NULL,10,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(20,'Fermi-GBM-spot6-e10-e50000-1000s','Fermi-GBM-spot6-e10-e50000-1000s',1,NULL,11,2,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(22,'Swift-spot6-e10-e50000-1000s','Swift-spot6-e10-e50000-1000s',1,NULL,11,3,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(23,'Swift-aitoff-e10-e50000-100s','Swift-aitoff-e10-e50000-100s',1,NULL,10,3,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(27,'Fermi-GBM-GRB-10s','Fermi-GBM_GRB_10s',1,NULL,4,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(28,'Fermi-GBM-GW-100s','Fermi-GBM_GW_100s',1,NULL,6,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(29,'Fermi-GBM-GW-10s','Fermi-GBM_GW_10s',1,NULL,6,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(30,'Fermi-GBM-GW-5s','Fermi-GBM_GW_5s',1,NULL,6,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(31,'MCAL ALERT','AGILE-MCAL_mcal_alert_full',1,NULL,2,4,-1000,1000,2000,2000,0,2000,1,'fast','fast_rt',1,4,NULL,180,1,0),
	(32,'MCAL ALERT partial coverage','AGILE-MCAL_mcal_alert_partial',1,NULL,2,4,-1000,1000,2000,0,2000,2000,1,'fast','fast_rt',1,4,NULL,180,1,0),
	(34,'AGILE-MCAL_GW-1000s','AGILE-MCAL_GW_1000s',1,NULL,6,4,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(37,'AGILE-MCAL-visCheckAux','AGILE-MCAL-visCheckAux',1,NULL,7,4,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(38,'AGILE-MCAL-ratemeters','AGILE-MCAL-ratemeters',1,NULL,8,4,-500,500,1000,1000,0,1000,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(39,'AGILE-MCAL-ATstatus','AGILE-MCAL-ATstatus',1,NULL,9,4,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(41,'AGILE-MCAL_GW-100s','AGILE-MCAL_GW_100s',1,NULL,6,4,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(42,'AGILE-MCAL_GW-10s','AGILE-MCAL_GW_10s',1,NULL,6,4,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(43,'AGILE-MCAL_GW-5s','AGILE-MCAL_GW_5s',1,NULL,6,4,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(44,'AGILE-MCAL-aitoff-e10-e50000-100s','AGILE-MCAL-aitoff-e10-e50000-100s',1,NULL,10,4,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(45,'AGILE-MCAL-spot6-e10-e50000-1000s','AGILE-MCAL-spot6-e10-e50000-1000s',1,NULL,11,4,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(47,'AGILE-MCAL-aitoff-e10-e50000-1000s','AGILE-MCAL-aitoff-e10-e50000-1000s',1,NULL,10,4,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(48,'AGILE-MCAL-aitoff-e10-e50000-10s','AGILE-MCAL-aitoff-e10-e50000-10s',1,NULL,10,4,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(49,'AGILE-MCAL-aitoff-e10-e50000-5s','AGILE-MCAL-aitoff-e10-e50000-5s',1,NULL,10,4,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(50,'Fermi-GBM-aitoff-e10-e50000-100s','Fermi-GBM-aitoff-e10-e50000-100s',1,NULL,10,2,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(51,'Fermi-GBM-aitoff-e10-e50000-10s','Fermi-GBM-aitoff-e10-e50000-10s',1,NULL,10,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(52,'Fermi-GBM-aitoff-e10-e50000-5s','Fermi-GBM-aitoff-e10-e50000-5s',1,NULL,10,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(53,'Fermi-GBM_MCAL-PLOT','Fermi-GBM_MCAL-PLOT',1,NULL,12,2,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(55,'AGILE-MCAL_MCAL-PLOT','AGILE-MCAL_MCAL-PLOT',1,NULL,12,4,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(57,'Fermi-GBM_GRID-UL-100s_FM3.119','Fermi-GBM_GRID-UL-100s_FM3.119',1,NULL,13,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(58,'AGILE-MCAL_GRID-UL-100s_FM3.119','AGILE-MCAL_GRID-UL-100s_FM3.119',1,NULL,13,4,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(59,'AGILE-MCAL_GRID-UL-1000s_FM3.119','AGILE-MCAL_GRID-UL-1000s_FM3.119',1,NULL,13,4,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(60,'AGILE-MCAL_GRID-UL-10s_FM3.119','AGILE-MCAL_GRID-UL-10s_FM3.119',1,NULL,13,4,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(61,'AGILE-MCAL_GRID-UL-5s_FM3.119','AGILE-MCAL_GRID-UL-5s_FM3.119',1,NULL,13,4,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(63,'Fermi-GBM_GRID-UL-10s_FM3.119','Fermi-GBM_GRID-UL-10s_FM3.119',1,NULL,13,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(64,'Fermi-GBM_GRID-UL-1000s_FM3.119','Fermi-GBM_GRID-UL-1000s_FM3.119',1,NULL,13,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(65,'Fermi-GBM_GRID-UL-5s_FM3.119','Fermi-GBM_GRID-UL-5s_FM3.119',1,NULL,13,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(66,'Swift-GW-100s','Swift_GW_100s',1,NULL,6,3,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(67,'Swift-GW-10s','Swift_GW_10s',1,NULL,6,3,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(68,'Swift-GW-5s','Swift_GW_5s',1,NULL,6,3,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(71,'Swift-aitoff-e10-e50000-1000s','Swift-aitoff-e10-e50000-1000s',1,NULL,10,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(72,'Swift-aitoff-e10-e50000-10s','Swift-aitoff-e10-e50000-10s',1,NULL,10,3,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(73,'Swift-aitoff-e10-e50000-5s','Swift-aitoff-e10-e50000-5s',1,NULL,10,3,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(74,'Swift_MCAL-PLOT','Swift_MCAL-PLOT',1,NULL,12,3,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(75,'Swift_GRID-UL-100s_FM3.119','Swift_GRID-UL-100s_FM3.119',1,NULL,13,3,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(76,'Swift_GRID-UL-10s_FM3.119','Swift_GRID-UL-10s_FM3.119',1,NULL,13,3,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(78,'Swift_GRID-UL-1000s_FM3.119','Swift_GRID-UL-1000s_FM3.119',1,NULL,13,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(80,'Swift_GRID-UL-5s_FM3.119','Swift_GRID-UL-5s_FM3.119',1,NULL,13,3,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(81,'Swift-GRB-5s','Swift_GRB_5s',1,NULL,4,3,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(130,'ICECUBE_GOLD-GW-100s','ICECUBE_GOLD_GW_100s',1,NULL,6,5,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(131,'ICECUBE_GOLD-GW-10s','ICECUBE_GOLD_GW_10s',1,NULL,6,5,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(132,'ICECUBE_GOLD-GW-5s','ICECUBE_GOLD_GW_5s',1,NULL,6,5,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(133,'ICECUBE_GOLD-aitoff-e10-e50000-1000s','ICECUBE_GOLD-aitoff-e10-e50000-1000s',1,NULL,10,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(134,'ICECUBE_GOLD-aitoff-e10-e50000-10s','ICECUBE_GOLD-aitoff-e10-e50000-10s',1,NULL,10,5,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(135,'ICECUBE_GOLD-aitoff-e10-e50000-5s','ICECUBE_GOLD-aitoff-e10-e50000-5s',1,NULL,10,5,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(136,'ICECUBE_GOLD_MCAL-PLOT','ICECUBE_GOLD_MCAL-PLOT',1,NULL,12,5,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(137,'ICECUBE_GOLD_GRID-UL-100s_FM3.119','ICECUBE_GOLD_GRID-UL-100s_FM3.119',1,NULL,13,5,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(138,'ICECUBE_GOLD_GRID-UL-10s_FM3.119','ICECUBE_GOLD_GRID-UL-10s_FM3.119',1,NULL,13,5,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(139,'ICECUBE_GOLD_GRID-UL-1000s_FM3.119','ICECUBE_GOLD_GRID-UL-1000s_FM3.119',1,NULL,13,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(140,'ICECUBE_GOLD_GRID-UL-5s_FM3.119','ICECUBE_GOLD_GRID-UL-5s_FM3.119',1,NULL,13,5,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(141,'ICECUBE_GOLD-GRB-5s','ICECUBE_GOLD_GRB_5s',1,NULL,4,5,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(142,'ICECUBE_GOLD-spot6-e10-e50000-1000s','ICECUBE_GOLD-spot6-e10-e50000-1000s',1,NULL,11,5,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(143,'ICECUBE_GOLD-aitoff-e10-e50000-100s','ICECUBE_GOLD-aitoff-e10-e50000-100s',1,NULL,10,5,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(144,'ICECUBE_GOLD-MCAL-ALERT','ICECUBE_GOLD_mcal_alert_full',1,NULL,2,5,-1000,1000,2000,2000,0,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(145,'ICECUBE_GOLD-MCAL-ALERT-partial-coverage','ICECUBE_GOLD_mcal_alert_partial',1,NULL,2,5,-1000,1000,2000,0,2000,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(146,'ICECUBE_GOLD-GRB-10s','ICECUBE_GOLD_GRB_10s',1,NULL,4,5,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(147,'ICECUBE_GOLD-GW-1000s','ICECUBE_GOLD_GW_1000s',1,NULL,6,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(148,'ICECUBE_GOLD-GRB-100s','ICECUBE_GOLD_GRB_100s',1,NULL,4,5,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(149,'ICECUBE_GOLD-GRB-1000s','ICECUBE_GOLD_GRB_1000s',1,NULL,4,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(150,'ICECUBE_GOLD-visCheckAux','ICECUBE_GOLD-visCheckAux',1,NULL,7,5,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(151,'ICECUBE_GOLD-ratemeters','ICECUBE_GOLD-ratemeters',1,NULL,8,5,-500,500,1000,1000,0,1000,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(152,'ICECUBE_GOLD-ATstatus','ICECUBE_GOLD-ATstatus',1,NULL,9,5,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(153,'ICECUBE_BRONZE-GW-100s','ICECUBE_BRONZE_GW_100s',1,NULL,6,7,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(154,'ICECUBE_BRONZE-GW-10s','ICECUBE_BRONZE_GW_10s',1,NULL,6,7,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(155,'ICECUBE_BRONZE-GW-5s','ICECUBE_BRONZE_GW_5s',1,NULL,6,7,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(156,'ICECUBE_BRONZE-aitoff-e10-e50000-1000s','ICECUBE_BRONZE-aitoff-e10-e50000-1000s',1,NULL,10,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(157,'ICECUBE_BRONZE-aitoff-e10-e50000-10s','ICECUBE_BRONZE-aitoff-e10-e50000-10s',1,NULL,10,7,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(158,'ICECUBE_BRONZE-aitoff-e10-e50000-5s','ICECUBE_BRONZE-aitoff-e10-e50000-5s',1,NULL,10,7,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(159,'ICECUBE_BRONZE_MCAL-PLOT','ICECUBE_BRONZE_MCAL-PLOT',1,NULL,12,7,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(160,'ICECUBE_BRONZE_GRID-UL-100s_FM3.119','ICECUBE_BRONZE_GRID-UL-100s_FM3.119',1,NULL,13,7,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(161,'ICECUBE_BRONZE_GRID-UL-10s_FM3.119','ICECUBE_BRONZE_GRID-UL-10s_FM3.119',1,NULL,13,7,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(162,'ICECUBE_BRONZE_GRID-UL-1000s_FM3.119','ICECUBE_BRONZE_GRID-UL-1000s_FM3.119',1,NULL,13,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(163,'ICECUBE_BRONZE_GRID-UL-5s_FM3.119','ICECUBE_BRONZE_GRID-UL-5s_FM3.119',1,NULL,13,7,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(164,'ICECUBE_BRONZE-GRB-5s','ICECUBE_BRONZE_GRB_5s',1,NULL,4,7,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(165,'ICECUBE_BRONZE-spot6-e10-e50000-1000s','ICECUBE_BRONZE-spot6-e10-e50000-1000s',1,NULL,11,7,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(166,'ICECUBE_BRONZE-aitoff-e10-e50000-100s','ICECUBE_BRONZE-aitoff-e10-e50000-100s',1,NULL,10,7,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(167,'ICECUBE_BRONZE-MCAL-ALERT','ICECUBE_BRONZE_mcal_alert_full',1,NULL,2,7,-1000,1000,2000,2000,0,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(168,'ICECUBE_BRONZE-MCAL-ALERT-partial-coverage','ICECUBE_BRONZE_mcal_alert_partial',1,NULL,2,7,-1000,1000,2000,0,2000,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(169,'ICECUBE_BRONZE-GRB-10s','ICECUBE_BRONZE_GRB_10s',1,NULL,4,7,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(170,'ICECUBE_BRONZE-GW-1000s','ICECUBE_BRONZE_GW_1000s',1,NULL,6,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(171,'ICECUBE_BRONZE-GRB-100s','ICECUBE_BRONZE_GRB_100s',1,NULL,4,7,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(172,'ICECUBE_BRONZE-GRB-1000s','ICECUBE_BRONZE_GRB_1000s',1,NULL,4,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(173,'ICECUBE_BRONZE-visCheckAux','ICECUBE_BRONZE-visCheckAux',1,NULL,7,7,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(174,'ICECUBE_BRONZE-ratemeters','ICECUBE_BRONZE-ratemeters',1,NULL,8,7,-500,500,1000,1000,0,1000,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(175,'ICECUBE_BRONZE-ATstatus','ICECUBE_BRONZE-ATstatus',1,NULL,9,7,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(176,'Fermi-GBM-FOV','Fermi-GBM-FOV',1,NULL,15,2,0,4,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(177,'ICECUBE_GOLD-FOV','ICECUBE_GOLD-FOV',1,NULL,15,5,0,4,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(178,'ICECUBE_BRONZE-FOV','ICECUBE_BRONZE-FOV',1,NULL,15,7,0,4,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(180,'Swift-FOV','Swift-FOV',1,NULL,15,3,0,4,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(181,'AGILE_MCAL-FOV','AGILE_MCAL-FOV',1,NULL,15,4,0,4,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(182,'Fermi-GBM-GRB-5s_FT3ab','Fermi-GBM_GRB_5s_FT3ab',1,NULL,16,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(183,'Fermi-GBM-GW-1000s_FT3ab','Fermi-GBM_GW_1000s_FT3ab',1,NULL,17,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(184,'Fermi-GBM-GRB-100s_FT3ab','Fermi-GBM_GRB_100s_FT3ab',1,NULL,16,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(185,'Fermi-GBM-GRB-1000s_FT3ab','Fermi-GBM_GRB_1000s_FT3ab',1,NULL,16,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(186,'Fermi-GBM-aitoff-e10-e50000-1000s_FT3ab','Fermi-GBM-aitoff-e10-e50000-1000s_FT3ab',1,NULL,18,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(187,'Fermi-GBM-spot6-e10-e50000-1000s_FT3ab','Fermi-GBM-spot6-e10-e50000-1000s_FT3ab',1,NULL,19,2,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(188,'Fermi-GBM-GRB-10s_FT3ab','Fermi-GBM_GRB_10s_FT3ab',1,NULL,16,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(189,'Fermi-GBM-GW-100s_FT3ab','Fermi-GBM_GW_100s_FT3ab',1,NULL,17,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(190,'Fermi-GBM-GW-10s_FT3ab','Fermi-GBM_GW_10s_FT3ab',1,NULL,17,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(191,'Fermi-GBM-GW-5s_FT3ab','Fermi-GBM_GW_5s_FT3ab',1,NULL,17,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(192,'Fermi-GBM-aitoff-e10-e50000-100s_FT3ab','Fermi-GBM-aitoff-e10-e50000-100s_FT3ab',1,NULL,18,2,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(193,'Fermi-GBM-aitoff-e10-e50000-10s_FT3ab','Fermi-GBM-aitoff-e10-e50000-10s_FT3ab',1,NULL,18,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(194,'Fermi-GBM-aitoff-e10-e50000-5s_FT3ab','Fermi-GBM-aitoff-e10-e50000-5s_FT3ab',1,NULL,18,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(195,'Fermi-GBM_GRID-UL-100s_FT3ab','Fermi-GBM_GRID-UL-100s_FT3ab',1,NULL,20,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(196,'Fermi-GBM_GRID-UL-10s_FT3ab','Fermi-GBM_GRID-UL-10s_FT3ab',1,NULL,20,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(197,'Fermi-GBM_GRID-UL-1000s_FT3ab','Fermi-GBM_GRID-UL-1000s_FT3ab',1,NULL,20,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(198,'Fermi-GBM_GRID-UL-5s_FT3ab','Fermi-GBM_GRID-UL-5s_FT3ab',1,NULL,20,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(199,'Swift-GRB-5s_FT3ab','Swift_GRB_5s_FT3ab',1,NULL,16,3,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(200,'Swift-GW-1000s_FT3ab','Swift_GW_1000s_FT3ab',1,NULL,17,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(201,'Swift-GRB-100s_FT3ab','Swift_GRB_100s_FT3ab',1,NULL,16,3,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(202,'Swift-GRB-1000s_FT3ab','Swift_GRB_1000s_FT3ab',1,NULL,16,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(203,'Swift-aitoff-e10-e50000-1000s_FT3ab','Swift-aitoff-e10-e50000-1000s_FT3ab',1,NULL,18,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(204,'Swift-spot6-e10-e50000-1000s_FT3ab','Swift-spot6-e10-e50000-1000s_FT3ab',1,NULL,19,3,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(205,'Swift-GRB-10s_FT3ab','Swift_GRB_10s_FT3ab',1,NULL,16,3,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(206,'Swift-GW-100s_FT3ab','Swift_GW_100s_FT3ab',1,NULL,17,3,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(207,'Swift-GW-10s_FT3ab','Swift_GW_10s_FT3ab',1,NULL,17,3,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(208,'Swift-GW-5s_FT3ab','Swift_GW_5s_FT3ab',1,NULL,17,3,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(209,'Swift-aitoff-e10-e50000-100s_FT3ab','Swift-aitoff-e10-e50000-100s_FT3ab',1,NULL,18,3,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(210,'Swift-aitoff-e10-e50000-10s_FT3ab','Swift-aitoff-e10-e50000-10s_FT3ab',1,NULL,18,3,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(211,'Swift-aitoff-e10-e50000-5s_FT3ab','Swift-aitoff-e10-e50000-5s_FT3ab',1,NULL,18,3,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(212,'Swift_GRID-UL-100s_FT3ab','Swift_GRID-UL-100s_FT3ab',1,NULL,20,3,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(213,'Swift_GRID-UL-10s_FT3ab','Swift_GRID-UL-10s_FT3ab',1,NULL,20,3,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(214,'Swift_GRID-UL-1000s_FT3ab','Swift_GRID-UL-1000s_FT3ab',1,NULL,20,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(215,'Swift_GRID-UL-5s_FT3ab','Swift_GRID-UL-5s_FT3ab',1,NULL,20,3,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(216,'AGILE_MCAL-GW-1000s_FT3ab','AGILE_MCAL_GW_1000s_FT3ab',1,NULL,17,4,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(217,'AGILE_MCAL-aitoff-e10-e50000-1000s_FT3ab','AGILE_MCAL-aitoff-e10-e50000-1000s_FT3ab',1,NULL,18,4,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(218,'AGILE_MCAL-spot6-e10-e50000-1000s_FT3ab','AGILE_MCAL-spot6-e10-e50000-1000s_FT3ab',1,NULL,19,4,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(219,'AGILE_MCAL-GW-100s_FT3ab','AGILE_MCAL_GW_100s_FT3ab',1,NULL,17,4,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(220,'AGILE_MCAL-GW-10s_FT3ab','AGILE_MCAL_GW_10s_FT3ab',1,NULL,17,4,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(221,'AGILE_MCAL-GW-5s_FT3ab','AGILE_MCAL_GW_5s_FT3ab',1,NULL,17,4,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(222,'AGILE_MCAL-aitoff-e10-e50000-100s_FT3ab','AGILE_MCAL-aitoff-e10-e50000-100s_FT3ab',1,NULL,18,4,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(223,'AGILE_MCAL-aitoff-e10-e50000-10s_FT3ab','AGILE_MCAL-aitoff-e10-e50000-10s_FT3ab',1,NULL,18,4,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(224,'AGILE_MCAL-aitoff-e10-e50000-5s_FT3ab','AGILE_MCAL-aitoff-e10-e50000-5s_FT3ab',1,NULL,18,4,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(225,'AGILE_MCAL_GRID-UL-100s_FT3ab','AGILE_MCAL_GRID-UL-100s_FT3ab',1,NULL,20,4,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(226,'AGILE_MCAL_GRID-UL-10s_FT3ab','AGILE_MCAL_GRID-UL-10s_FT3ab',1,NULL,20,4,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(227,'AGILE_MCAL_GRID-UL-1000s_FT3ab','AGILE_MCAL_GRID-UL-1000s_FT3ab',1,NULL,20,4,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(228,'AGILE_MCAL_GRID-UL-5s_FT3ab','AGILE_MCAL_GRID-UL-5s_FT3ab',1,NULL,20,4,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(246,'ICECUBE_BRONZE-GRB-5s_FT3ab','ICECUBE_BRONZE_GRB_5s_FT3ab',1,NULL,16,7,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(247,'ICECUBE_BRONZE-GRB-10s_FT3ab','ICECUBE_BRONZE_GRB_10s_FT3ab',1,NULL,16,7,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(248,'ICECUBE_BRONZE-GRB-100s_FT3ab','ICECUBE_BRONZE_GRB_100s_FT3ab',1,NULL,16,7,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(249,'ICECUBE_BRONZE-GRB-1000s_FT3ab','ICECUBE_BRONZE_GRB_1000s_FT3ab',1,NULL,16,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(250,'ICECUBE_BRONZE-GW-1000s_FT3ab','ICECUBE_BRONZE_GW_1000s_FT3ab',1,NULL,17,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(251,'ICECUBE_BRONZE-aitoff-e10-e50000-1000s_FT3ab','ICECUBE_BRONZE-aitoff-e10-e50000-1000s_FT3ab',1,NULL,18,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(252,'ICECUBE_BRONZE-spot6-e10-e50000-1000s_FT3ab','ICECUBE_BRONZE-spot6-e10-e50000-1000s_FT3ab',1,NULL,19,7,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(253,'ICECUBE_BRONZE-GW-100s_FT3ab','ICECUBE_BRONZE_GW_100s_FT3ab',1,NULL,17,7,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(254,'ICECUBE_BRONZE-GW-10s_FT3ab','ICECUBE_BRONZE_GW_10s_FT3ab',1,NULL,17,7,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(255,'ICECUBE_BRONZE-GW-5s_FT3ab','ICECUBE_BRONZE_GW_5s_FT3ab',1,NULL,17,7,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(256,'ICECUBE_BRONZE-aitoff-e10-e50000-100s_FT3ab','ICECUBE_BRONZE-aitoff-e10-e50000-100s_FT3ab',1,NULL,18,7,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(257,'ICECUBE_BRONZE-aitoff-e10-e50000-10s_FT3ab','ICECUBE_BRONZE-aitoff-e10-e50000-10s_FT3ab',1,NULL,18,7,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(258,'ICECUBE_BRONZE-aitoff-e10-e50000-5s_FT3ab','ICECUBE_BRONZE-aitoff-e10-e50000-5s_FT3ab',1,NULL,18,7,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(259,'ICECUBE_BRONZE_GRID-UL-100s_FT3ab','ICECUBE_BRONZE_GRID-UL-100s_FT3ab',1,NULL,20,7,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(260,'ICECUBE_BRONZE_GRID-UL-10s_FT3ab','ICECUBE_BRONZE_GRID-UL-10s_FT3ab',1,NULL,20,7,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(261,'ICECUBE_BRONZE_GRID-UL-1000s_FT3ab','ICECUBE_BRONZE_GRID-UL-1000s_FT3ab',1,NULL,20,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(262,'ICECUBE_BRONZE_GRID-UL-5s_FT3ab','ICECUBE_BRONZE_GRID-UL-5s_FT3ab',1,NULL,20,7,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(263,'ICECUBE_GOLD-GRB-5s_FT3ab','ICECUBE_GOLD_GRB_5s_FT3ab',1,NULL,16,5,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(264,'ICECUBE_GOLD-GRB-10s_FT3ab','ICECUBE_GOLD_GRB_10s_FT3ab',1,NULL,16,5,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(265,'ICECUBE_GOLD-GRB-100s_FT3ab','ICECUBE_GOLD_GRB_100s_FT3ab',1,NULL,16,5,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(266,'ICECUBE_GOLD-GRB-1000s_FT3ab','ICECUBE_GOLD_GRB_1000s_FT3ab',1,NULL,16,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(267,'ICECUBE_GOLD-GW-1000s_FT3ab','ICECUBE_GOLD_GW_1000s_FT3ab',1,NULL,17,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(268,'ICECUBE_GOLD-aitoff-e10-e50000-1000s_FT3ab','ICECUBE_GOLD-aitoff-e10-e50000-1000s_FT3ab',1,NULL,18,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(269,'ICECUBE_GOLD-spot6-e10-e50000-1000s_FT3ab','ICECUBE_GOLD-spot6-e10-e50000-1000s_FT3ab',1,NULL,19,5,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(270,'ICECUBE_GOLD-GW-100s_FT3ab','ICECUBE_GOLD_GW_100s_FT3ab',1,NULL,17,5,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(271,'ICECUBE_GOLD-GW-10s_FT3ab','ICECUBE_GOLD_GW_10s_FT3ab',1,NULL,17,5,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(272,'ICECUBE_GOLD-GW-5s_FT3ab','ICECUBE_GOLD_GW_5s_FT3ab',1,NULL,17,5,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(273,'ICECUBE_GOLD-aitoff-e10-e50000-100s_FT3ab','ICECUBE_GOLD-aitoff-e10-e50000-100s_FT3ab',1,NULL,18,5,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(274,'ICECUBE_GOLD-aitoff-e10-e50000-10s_FT3ab','ICECUBE_GOLD-aitoff-e10-e50000-10s_FT3ab',1,NULL,18,5,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(275,'ICECUBE_GOLD-aitoff-e10-e50000-5s_FT3ab','ICECUBE_GOLD-aitoff-e10-e50000-5s_FT3ab',1,NULL,18,5,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(276,'ICECUBE_GOLD_GRID-UL-100s_FT3ab','ICECUBE_GOLD_GRID-UL-100s_FT3ab',1,NULL,20,5,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(277,'ICECUBE_GOLD_GRID-UL-10s_FT3ab','ICECUBE_GOLD_GRID-UL-10s_FT3ab',1,NULL,20,5,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(278,'ICECUBE_GOLD_GRID-UL-1000s_FT3ab','ICECUBE_GOLD_GRID-UL-1000s_FT3ab',1,NULL,20,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(279,'ICECUBE_GOLD_GRID-UL-5s_FT3ab','ICECUBE_GOLD_GRID-UL-5s_FT3ab',1,NULL,20,5,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(281,'AGILE_MCAL_AU-GW+-10s_FT3ab','AGILE_MCAL_AU-GW+-10s_FT3ab',1,NULL,17,8,-10,10,20,20,0,20,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(282,'AGILE-MCAL-AU_GW+-10s','AGILE-MCAL-AU_GW+-10s',1,NULL,6,8,-10,10,20,20,0,20,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(283,'AGILE_MCAL_AU-aitoff-e10-e50000+-10s_FT3ab','AGILE_MCAL_AU-aitoff-e10-e50000+-10s_FT3ab',1,NULL,18,8,-10,10,20,20,0,20,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(284,'AGILE_MCAL_AU-aitoff-e10-e50000+-10s','AGILE_MCAL_AU-aitoff-e10-e50000+-10s',1,NULL,10,8,-10,10,20,20,0,20,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(359,'Fermi-GBM-GRB-5s_lm5','Fermi-GBM_GRB_5s_lm5',1,NULL,21,2,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(360,'Fermi-GBM-GW-1000s_lm5','Fermi-GBM_GW_1000s_lm5',1,NULL,23,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(361,'Fermi-GBM-GRB-100s_lm5','Fermi-GBM_GRB_100s_lm5',1,NULL,21,2,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(362,'Fermi-GBM-GRB-1000s_lm5','Fermi-GBM_GRB_1000s_lm5',1,NULL,21,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(363,'Swift-GRB-10s_lm5','Swift_GRB_10s_lm5',1,NULL,21,3,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(364,'Swift-GW-1000s_lm5','Swift_GW_1000s_lm5',1,NULL,23,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(365,'Swift-GRB-100s_lm5','Swift_GRB_100s_lm5',1,NULL,21,3,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(366,'Swift-GRB-1000s_lm5','Swift_GRB_1000s_lm5',1,NULL,21,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(367,'Fermi-GBM-GRB-10s_lm5','Fermi-GBM_GRB_10s_lm5',1,NULL,21,2,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(368,'Fermi-GBM-GW-100s_lm5','Fermi-GBM_GW_100s_lm5',1,NULL,23,2,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(369,'Fermi-GBM-GW-10s_lm5','Fermi-GBM_GW_10s_lm5',1,NULL,23,2,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(370,'Fermi-GBM-GW-5s_lm5','Fermi-GBM_GW_5s_lm5',1,NULL,23,2,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(371,'AGILE-MCAL_GW-1000s_lm5','AGILE-MCAL_GW_1000s_lm5',1,NULL,23,4,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(372,'AGILE-MCAL_GW-100s_lm5','AGILE-MCAL_GW_100s_lm5',1,NULL,23,4,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(373,'AGILE-MCAL_GW-10s_lm5','AGILE-MCAL_GW_10s_lm5',1,NULL,23,4,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(374,'AGILE-MCAL_GW-5s_lm5','AGILE-MCAL_GW_5s_lm5',1,NULL,23,4,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(375,'Swift-GW-100s_lm5','Swift_GW_100s_lm5',1,NULL,23,3,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(376,'Swift-GW-10s_lm5','Swift_GW_10s_lm5',1,NULL,23,3,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(377,'Swift-GW-5s_lm5','Swift_GW_5s_lm5',1,NULL,23,3,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(378,'Swift-GRB-5s_lm5','Swift_GRB_5s_lm5',1,NULL,21,3,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(379,'ICECUBE_GOLD-GW-100s_lm5','ICECUBE_GOLD_GW_100s_lm5',1,NULL,23,5,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(380,'ICECUBE_GOLD-GW-10s_lm5','ICECUBE_GOLD_GW_10s_lm5',1,NULL,23,5,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(381,'ICECUBE_GOLD-GW-5s_lm5','ICECUBE_GOLD_GW_5s_lm5',1,NULL,23,5,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(382,'ICECUBE_GOLD-GRB-5s_lm5','ICECUBE_GOLD_GRB_5s_lm5',1,NULL,21,5,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(383,'ICECUBE_GOLD-GRB-10s_lm5','ICECUBE_GOLD_GRB_10s_lm5',1,NULL,21,5,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(384,'ICECUBE_GOLD-GW-1000s_lm5','ICECUBE_GOLD_GW_1000s_lm5',1,NULL,23,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(385,'ICECUBE_GOLD-GRB-100s_lm5','ICECUBE_GOLD_GRB_100s_lm5',1,NULL,21,5,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(386,'ICECUBE_GOLD-GRB-1000s_lm5','ICECUBE_GOLD_GRB_1000s_lm5',1,NULL,21,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(387,'ICECUBE_BRONZE-GW-100s_lm5','ICECUBE_BRONZE_GW_100s_lm5',1,NULL,23,7,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(388,'ICECUBE_BRONZE-GW-10s_lm5','ICECUBE_BRONZE_GW_10s_lm5',1,NULL,23,7,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(389,'ICECUBE_BRONZE-GW-5s_lm5','ICECUBE_BRONZE_GW_5s_lm5',1,NULL,23,7,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(390,'ICECUBE_BRONZE-GRB-5s_lm5','ICECUBE_BRONZE_GRB_5s_lm5',1,NULL,21,7,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(391,'ICECUBE_BRONZE-GRB-10s_lm5','ICECUBE_BRONZE_GRB_10s_lm5',1,NULL,21,7,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(392,'ICECUBE_BRONZE-GW-1000s_lm5','ICECUBE_BRONZE_GW_1000s_lm5',1,NULL,23,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(393,'ICECUBE_BRONZE-GRB-100s_lm5','ICECUBE_BRONZE_GRB_100s_lm5',1,NULL,21,7,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(394,'ICECUBE_BRONZE-GRB-1000s_lm5','ICECUBE_BRONZE_GRB_1000s_lm5',1,NULL,21,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(395,'Fermi-GBM-GRB-5s_FT3ab_lm5','Fermi-GBM_GRB_5s_FT3ab_lm5',1,NULL,25,2,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(396,'Fermi-GBM-GW-1000s_FT3ab_lm5','Fermi-GBM_GW_1000s_FT3ab_lm5',1,NULL,26,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(397,'Fermi-GBM-GRB-100s_FT3ab_lm5','Fermi-GBM_GRB_100s_FT3ab_lm5',1,NULL,25,2,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(398,'Fermi-GBM-GRB-1000s_FT3ab_lm5','Fermi-GBM_GRB_1000s_FT3ab_lm5',1,NULL,25,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(399,'Fermi-GBM-GRB-10s_FT3ab_lm5','Fermi-GBM_GRB_10s_FT3ab_lm5',1,NULL,25,2,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(400,'Fermi-GBM-GW-100s_FT3ab_lm5','Fermi-GBM_GW_100s_FT3ab_lm5',1,NULL,26,2,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(401,'Fermi-GBM-GW-10s_FT3ab_lm5','Fermi-GBM_GW_10s_FT3ab_lm5',1,NULL,26,2,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(402,'Fermi-GBM-GW-5s_FT3ab_lm5','Fermi-GBM_GW_5s_FT3ab_lm5',1,NULL,26,2,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(403,'Swift-GRB-5s_FT3ab_lm5','Swift_GRB_5s_FT3ab_lm5',1,NULL,25,3,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(404,'Swift-GW-1000s_FT3ab_lm5','Swift_GW_1000s_FT3ab_lm5',1,NULL,26,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(405,'Swift-GRB-100s_FT3ab_lm5','Swift_GRB_100s_FT3ab_lm5',1,NULL,25,3,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(406,'Swift-GRB-1000s_FT3ab_lm5','Swift_GRB_1000s_FT3ab_lm5',1,NULL,25,3,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(407,'Swift-GRB-10s_FT3ab_lm5','Swift_GRB_10s_FT3ab_lm5',1,NULL,25,3,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(408,'Swift-GW-100s_FT3ab_lm5','Swift_GW_100s_FT3ab_lm5',1,NULL,26,3,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(409,'Swift-GW-10s_FT3ab_lm5','Swift_GW_10s_FT3ab_lm5',1,NULL,26,3,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(410,'Swift-GW-5s_FT3ab_lm5','Swift_GW_5s_FT3ab_lm5',1,NULL,26,3,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(411,'AGILE_MCAL-GW-1000s_FT3ab_lm5','AGILE_MCAL_GW_1000s_FT3ab_lm5',1,NULL,26,4,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(412,'AGILE_MCAL-GW-100s_FT3ab_lm5','AGILE_MCAL_GW_100s_FT3ab_lm5',1,NULL,26,4,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(413,'AGILE_MCAL-GW-10s_FT3ab_lm5','AGILE_MCAL_GW_10s_FT3ab_lm5',1,NULL,26,4,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(414,'AGILE_MCAL-GW-5s_FT3ab_lm5','AGILE_MCAL_GW_5s_FT3ab_lm5',1,NULL,26,4,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(415,'ICECUBE_BRONZE-GRB-5s_FT3ab_lm5','ICECUBE_BRONZE_GRB_5s_FT3ab_lm5',1,NULL,25,7,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(416,'ICECUBE_BRONZE-GRB-10s_FT3ab_lm5','ICECUBE_BRONZE_GRB_10s_FT3ab_lm5',1,NULL,25,7,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(417,'ICECUBE_BRONZE-GRB-100s_FT3ab_lm5','ICECUBE_BRONZE_GRB_100s_FT3ab_lm5',1,NULL,25,7,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(418,'ICECUBE_BRONZE-GRB-1000s_FT3ab_lm5','ICECUBE_BRONZE_GRB_1000s_FT3ab_lm5',1,NULL,25,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(419,'ICECUBE_BRONZE-GW-1000s_FT3ab_lm5','ICECUBE_BRONZE_GW_1000s_FT3ab_lm5',1,NULL,26,7,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(420,'ICECUBE_BRONZE-GW-100s_FT3ab_lm5','ICECUBE_BRONZE_GW_100s_FT3ab_lm5',1,NULL,26,7,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(421,'ICECUBE_BRONZE-GW-10s_FT3ab_lm5','ICECUBE_BRONZE_GW_10s_FT3ab_lm5',1,NULL,26,7,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(422,'ICECUBE_BRONZE-GW-5s_FT3ab_lm5','ICECUBE_BRONZE_GW_5s_FT3ab_lm5',1,NULL,26,7,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(423,'ICECUBE_GOLD-GRB-5s_FT3ab_lm5','ICECUBE_GOLD_GRB_5s_FT3ab_lm5',1,NULL,25,5,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(424,'ICECUBE_GOLD-GRB-10s_FT3ab_lm5','ICECUBE_GOLD_GRB_10s_FT3ab_lm5',1,NULL,25,5,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(425,'ICECUBE_GOLD-GRB-100s_FT3ab_lm5','ICECUBE_GOLD_GRB_100s_FT3ab_lm5',1,NULL,25,5,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(426,'ICECUBE_GOLD-GRB-1000s_FT3ab_lm5','ICECUBE_GOLD_GRB_1000s_FT3ab_lm5',1,NULL,25,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(427,'ICECUBE_GOLD-GW-1000s_FT3ab_lm5','ICECUBE_GOLD_GW_1000s_FT3ab_lm5',1,NULL,26,5,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(428,'ICECUBE_GOLD-GW-100s_FT3ab_lm5','ICECUBE_GOLD_GW_100s_FT3ab_lm5',1,NULL,26,5,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(429,'ICECUBE_GOLD-GW-10s_FT3ab_lm5','ICECUBE_GOLD_GW_10s_FT3ab_lm5',1,NULL,26,5,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(430,'ICECUBE_GOLD-GW-5s_FT3ab_lm5','ICECUBE_GOLD_GW_5s_FT3ab_lm5',1,NULL,26,5,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(431,'AGILE_MCAL_AU-GW+-10s_FT3ab_lm5','AGILE_MCAL_AU-GW+-10s_FT3ab_lm5',1,NULL,26,8,-10,10,20,20,0,20,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(432,'AGILE-MCAL-AU_GW+-10s_lm5','AGILE-MCAL-AU_GW+-10s_lm5',1,NULL,23,8,-10,10,20,20,0,20,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(433,'LIGO-GRB-5s','LIGO_GRB_5s',1,NULL,4,1,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(434,'LIGO-GW-1000s','LIGO_GW_1000s',1,NULL,6,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(435,'LIGO-GRB-100s','LIGO_GRB_100s',1,NULL,4,1,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(436,'LIGO-GRB-1000s','LIGO_GRB_1000s',1,NULL,4,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(437,'LIGO-visCheckAux','LIGO-visCheckAux',1,NULL,7,1,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(438,'LIGO-ratemeters','LIGO-ratemeters',1,NULL,8,1,-500,500,1000,1000,0,1000,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(439,'LIGO-ATstatus','LIGO-ATstatus',1,NULL,9,1,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(440,'LIGO-aitoff-e10-e50000-1000s','LIGO-aitoff-e10-e50000-1000s',1,NULL,10,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(441,'LIGO-spot6-e10-e50000-1000s','LIGO-spot6-e10-e50000-1000s',1,NULL,11,1,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(442,'LIGO-GRB-10s','LIGO_GRB_10s',1,NULL,4,1,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(443,'LIGO-GW-100s','LIGO_GW_100s',1,NULL,6,1,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(444,'LIGO-GW-10s','LIGO_GW_10s',1,NULL,6,1,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(445,'LIGO-GW-5s','LIGO_GW_5s',1,NULL,6,1,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(446,'LIGO-aitoff-e10-e50000-100s','LIGO-aitoff-e10-e50000-100s',1,NULL,10,1,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(447,'LIGO-aitoff-e10-e50000-10s','LIGO-aitoff-e10-e50000-10s',1,NULL,10,1,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(448,'LIGO-aitoff-e10-e50000-5s','LIGO-aitoff-e10-e50000-5s',1,NULL,10,1,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(449,'LIGO_MCAL-PLOT','LIGO_MCAL-PLOT',1,NULL,12,1,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(450,'LIGO_GRID-UL-100s_FM3.119','LIGO_GRID-UL-100s_FM3.119',1,NULL,13,1,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(451,'LIGO_GRID-UL-10s_FM3.119','LIGO_GRID-UL-10s_FM3.119',1,NULL,13,1,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(452,'LIGO_GRID-UL-1000s_FM3.119','LIGO_GRID-UL-1000s_FM3.119',1,NULL,13,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(453,'LIGO_GRID-UL-5s_FM3.119','LIGO_GRID-UL-5s_FM3.119',1,NULL,13,1,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(454,'LIGO-GRB-5s_FT3ab','LIGO_GRB_5s_FT3ab',1,NULL,16,1,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(455,'LIGO-GW-1000s_FT3ab','LIGO_GW_1000s_FT3ab',1,NULL,17,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(456,'LIGO-GRB-100s_FT3ab','LIGO_GRB_100s_FT3ab',1,NULL,16,1,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(457,'LIGO-GRB-1000s_FT3ab','LIGO_GRB_1000s_FT3ab',1,NULL,16,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(458,'LIGO-aitoff-e10-e50000-1000s_FT3ab','LIGO-aitoff-e10-e50000-1000s_FT3ab',1,NULL,18,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(459,'LIGO-spot6-e10-e50000-1000s_FT3ab','LIGO-spot6-e10-e50000-1000s_FT3ab',1,NULL,19,1,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(460,'LIGO-GRB-10s_FT3ab','LIGO_GRB_10s_FT3ab',1,NULL,16,1,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(461,'LIGO-GW-100s_FT3ab','LIGO_GW_100s_FT3ab',1,NULL,17,1,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(462,'LIGO-GW-10s_FT3ab','LIGO_GW_10s_FT3ab',1,NULL,17,1,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(463,'LIGO-GW-5s_FT3ab','LIGO_GW_5s_FT3ab',1,NULL,17,1,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(464,'LIGO-aitoff-e10-e50000-100s_FT3ab','LIGO-aitoff-e10-e50000-100s_FT3ab',1,NULL,18,1,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(465,'LIGO-aitoff-e10-e50000-10s_FT3ab','LIGO-aitoff-e10-e50000-10s_FT3ab',1,NULL,18,1,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(466,'LIGO-aitoff-e10-e50000-5s_FT3ab','LIGO-aitoff-e10-e50000-5s_FT3ab',1,NULL,18,1,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(467,'LIGO_GRID-UL-100s_FT3ab','LIGO_GRID-UL-100s_FT3ab',1,NULL,20,1,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(468,'LIGO_GRID-UL-10s_FT3ab','LIGO_GRID-UL-10s_FT3ab',1,NULL,20,1,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(469,'LIGO_GRID-UL-1000s_FT3ab','LIGO_GRID-UL-1000s_FT3ab',1,NULL,20,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(470,'LIGO_GRID-UL-5s_FT3ab','LIGO_GRID-UL-5s_FT3ab',1,NULL,20,1,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(471,'LIGO-GRB-5s_lm5','LIGO_GRB_5s_lm5',1,NULL,21,1,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(472,'LIGO-GW-1000s_lm5','LIGO_GW_1000s_lm5',1,NULL,23,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(473,'LIGO-GRB-100s_lm5','LIGO_GRB_100s_lm5',1,NULL,21,1,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(474,'LIGO-GRB-1000s_lm5','LIGO_GRB_1000s_lm5',1,NULL,21,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(475,'LIGO-GRB-10s_lm5','LIGO_GRB_10s_lm5',1,NULL,21,1,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(476,'LIGO-GW-100s_lm5','LIGO_GW_100s_lm5',1,NULL,23,1,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(477,'LIGO-GW-10s_lm5','LIGO_GW_10s_lm5',1,NULL,23,1,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(478,'LIGO-GW-5s_lm5','LIGO_GW_5s_lm5',1,NULL,23,1,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(479,'LIGO-GRB-5s_FT3ab_lm5','LIGO_GRB_5s_FT3ab_lm5',1,NULL,25,1,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(480,'LIGO-GW-1000s_FT3ab_lm5','LIGO_GW_1000s_FT3ab_lm5',1,NULL,26,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(481,'LIGO-GRB-100s_FT3ab_lm5','LIGO_GRB_100s_FT3ab_lm5',1,NULL,25,1,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(482,'LIGO-GRB-1000s_FT3ab_lm5','LIGO_GRB_1000s_FT3ab_lm5',1,NULL,25,1,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(483,'LIGO-GRB-10s_FT3ab_lm5','LIGO_GRB_10s_FT3ab_lm5',1,NULL,25,1,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(484,'LIGO-GW-100s_FT3ab_lm5','LIGO_GW_100s_FT3ab_lm5',1,NULL,26,1,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(485,'LIGO-GW-10s_FT3ab_lm5','LIGO_GW_10s_FT3ab_lm5',1,NULL,26,1,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(486,'LIGO-GW-5s_FT3ab_lm5','LIGO_GW_5s_FT3ab_lm5',1,NULL,26,1,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(487,'LIGO-FOV','LIGO-FOV',1,NULL,15,1,0,4,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(488,'LIGO-MCAL-ALERT-partial-coverage','LIGO-MCAL-ALERT-partial-coverage',1,NULL,2,1,-1000,1000,2000,0,2000,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(491,'LIGO-MCAL-ALERT','LIGO-MCAL-ALERT',1,NULL,2,1,-1000,1000,2000,2000,0,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(549,'LIGO_TEST-GRB-5s','LIGO_TEST_GRB_5s',1,NULL,4,18,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(550,'LIGO_TEST-GW-1000s','LIGO_TEST_GW_1000s',1,NULL,6,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(551,'LIGO_TEST-GRB-100s','LIGO_TEST_GRB_100s',1,NULL,4,18,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(552,'LIGO_TEST-GRB-1000s','LIGO_TEST_GRB_1000s',1,NULL,4,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(553,'LIGO_TEST-visCheckAux','LIGO_TEST-visCheckAux',1,NULL,7,18,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(554,'LIGO_TEST-ratemeters','LIGO_TEST-ratemeters',1,NULL,8,18,-500,500,1000,1000,0,1000,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(555,'LIGO_TEST-ATstatus','LIGO_TEST-ATstatus',1,NULL,9,18,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(556,'LIGO_TEST-aitoff-e10-e50000-1000s','LIGO_TEST-aitoff-e10-e50000-1000s',1,NULL,10,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(557,'LIGO_TEST-spot6-e10-e50000-1000s','LIGO_TEST-spot6-e10-e50000-1000s',1,NULL,11,18,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(558,'LIGO_TEST-GRB-10s','LIGO_TEST_GRB_10s',1,NULL,4,18,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(559,'LIGO_TEST-GW-100s','LIGO_TEST_GW_100s',1,NULL,6,18,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(560,'LIGO_TEST-GW-10s','LIGO_TEST_GW_10s',1,NULL,6,18,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(561,'LIGO_TEST-GW-5s','LIGO_TEST_GW_5s',1,NULL,6,18,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(562,'LIGO_TEST-aitoff-e10-e50000-100s','LIGO_TEST-aitoff-e10-e50000-100s',1,NULL,10,18,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(563,'LIGO_TEST-aitoff-e10-e50000-10s','LIGO_TEST-aitoff-e10-e50000-10s',1,NULL,10,18,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(564,'LIGO_TEST-aitoff-e10-e50000-5s','LIGO_TEST-aitoff-e10-e50000-5s',1,NULL,10,18,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(565,'LIGO_TEST_MCAL-PLOT','LIGO_TEST_MCAL-PLOT',1,NULL,12,18,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(566,'LIGO_TEST_GRID-UL-100s_FM3.119','LIGO_TEST_GRID-UL-100s_FM3.119',1,NULL,13,18,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(567,'LIGO_TEST_GRID-UL-10s_FM3.119','LIGO_TEST_GRID-UL-10s_FM3.119',1,NULL,13,18,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(568,'LIGO_TEST_GRID-UL-1000s_FM3.119','LIGO_TEST_GRID-UL-1000s_FM3.119',1,NULL,13,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(569,'LIGO_TEST_GRID-UL-5s_FM3.119','LIGO_TEST_GRID-UL-5s_FM3.119',1,NULL,13,18,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(570,'LIGO_TEST-GRB-5s_FT3ab','LIGO_TEST_GRB_5s_FT3ab',1,NULL,16,18,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(571,'LIGO_TEST-GW-1000s_FT3ab','LIGO_TEST_GW_1000s_FT3ab',1,NULL,17,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(572,'LIGO_TEST-GRB-100s_FT3ab','LIGO_TEST_GRB_100s_FT3ab',1,NULL,16,18,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(573,'LIGO_TEST-GRB-1000s_FT3ab','LIGO_TEST_GRB_1000s_FT3ab',1,NULL,16,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(574,'LIGO_TEST-aitoff-e10-e50000-1000s_FT3ab','LIGO_TEST-aitoff-e10-e50000-1000s_FT3ab',1,NULL,18,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(575,'LIGO_TEST-spot6-e10-e50000-1000s_FT3ab','LIGO_TEST-spot6-e10-e50000-1000s_FT3ab',1,NULL,19,18,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(576,'LIGO_TEST-GRB-10s_FT3ab','LIGO_TEST_GRB_10s_FT3ab',1,NULL,16,18,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(577,'LIGO_TEST-GW-100s_FT3ab','LIGO_TEST_GW_100s_FT3ab',1,NULL,17,18,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(578,'LIGO_TEST-GW-10s_FT3ab','LIGO_TEST_GW_10s_FT3ab',1,NULL,17,18,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(579,'LIGO_TEST-GW-5s_FT3ab','LIGO_TEST_GW_5s_FT3ab',1,NULL,17,18,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(580,'LIGO_TEST-aitoff-e10-e50000-100s_FT3ab','LIGO_TEST-aitoff-e10-e50000-100s_FT3ab',1,NULL,18,18,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(581,'LIGO_TEST-aitoff-e10-e50000-10s_FT3ab','LIGO_TEST-aitoff-e10-e50000-10s_FT3ab',1,NULL,18,18,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(582,'LIGO_TEST-aitoff-e10-e50000-5s_FT3ab','LIGO_TEST-aitoff-e10-e50000-5s_FT3ab',1,NULL,18,18,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(583,'LIGO_TEST_GRID-UL-100s_FT3ab','LIGO_TEST_GRID-UL-100s_FT3ab',1,NULL,20,18,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(584,'LIGO_TEST_GRID-UL-10s_FT3ab','LIGO_TEST_GRID-UL-10s_FT3ab',1,NULL,20,18,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(585,'LIGO_TEST_GRID-UL-1000s_FT3ab','LIGO_TEST_GRID-UL-1000s_FT3ab',1,NULL,20,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(586,'LIGO_TEST_GRID-UL-5s_FT3ab','LIGO_TEST_GRID-UL-5s_FT3ab',1,NULL,20,18,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(587,'LIGO_TEST-GRB-5s_lm5','LIGO_TEST_GRB_5s_lm5',1,NULL,21,18,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(588,'LIGO_TEST-GW-1000s_lm5','LIGO_TEST_GW_1000s_lm5',1,NULL,23,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(589,'LIGO_TEST-GRB-100s_lm5','LIGO_TEST_GRB_100s_lm5',1,NULL,21,18,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(590,'LIGO_TEST-GRB-1000s_lm5','LIGO_TEST_GRB_1000s_lm5',1,NULL,21,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(591,'LIGO_TEST-GRB-10s_lm5','LIGO_TEST_GRB_10s_lm5',1,NULL,21,18,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(592,'LIGO_TEST-GW-100s_lm5','LIGO_TEST_GW_100s_lm5',1,NULL,23,18,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(593,'LIGO_TEST-GW-10s_lm5','LIGO_TEST_GW_10s_lm5',1,NULL,23,18,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(594,'LIGO_TEST-GW-5s_lm5','LIGO_TEST_GW_5s_lm5',1,NULL,23,18,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(595,'LIGO_TEST-GRB-5s_FT3ab_lm5','LIGO_TEST_GRB_5s_FT3ab_lm5',1,NULL,25,18,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(596,'LIGO_TEST-GW-1000s_FT3ab_lm5','LIGO_TEST_GW_1000s_FT3ab_lm5',1,NULL,26,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(597,'LIGO_TEST-GRB-100s_FT3ab_lm5','LIGO_TEST_GRB_100s_FT3ab_lm5',1,NULL,25,18,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(598,'LIGO_TEST-GRB-1000s_FT3ab_lm5','LIGO_TEST_GRB_1000s_FT3ab_lm5',1,NULL,25,18,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(599,'LIGO_TEST-GRB-10s_FT3ab_lm5','LIGO_TEST_GRB_10s_FT3ab_lm5',1,NULL,25,18,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(600,'LIGO_TEST-GW-100s_FT3ab_lm5','LIGO_TEST_GW_100s_FT3ab_lm5',1,NULL,26,18,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(601,'LIGO_TEST-GW-10s_FT3ab_lm5','LIGO_TEST_GW_10s_FT3ab_lm5',1,NULL,26,18,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(602,'LIGO_TEST-GW-5s_FT3ab_lm5','LIGO_TEST_GW_5s_FT3ab_lm5',1,NULL,26,18,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(603,'LIGO_TEST-FOV','LIGO_TEST-FOV',1,NULL,15,18,0,4,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(604,'LIGO_TEST-MCAL-ALERT-partial-coverage','LIGO_TEST-MCAL-ALERT-partial-coverage',1,NULL,2,18,-1000,1000,2000,0,2000,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(605,'LIGO_TEST-MCAL-ALERT','LIGO_TEST-MCAL-ALERT',1,NULL,2,18,-1000,1000,2000,2000,0,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(606,'FRB-GRB-5s','FRB_GRB_5s',1,NULL,4,20,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(607,'FRB-GW-1000s','FRB_GW_1000s',1,NULL,6,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(608,'FRB-GRB-100s','FRB_GRB_100s',1,NULL,4,20,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(609,'FRB-GRB-1000s','FRB_GRB_1000s',1,NULL,4,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(610,'FRB-visCheckAux','FRB-visCheckAux',1,NULL,7,20,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(611,'FRB-ratemeters','FRB-ratemeters',1,NULL,8,20,-500,500,1000,1000,0,1000,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(612,'FRB-ATstatus','FRB-ATstatus',1,NULL,9,20,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(613,'FRB-aitoff-e10-e50000-1000s','FRB-aitoff-e10-e50000-1000s',1,NULL,10,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(614,'FRB-spot6-e10-e50000-1000s','FRB-spot6-e10-e50000-1000s',1,NULL,11,20,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(615,'FRB-GRB-10s','FRB_GRB_10s',1,NULL,4,20,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(616,'FRB-GW-100s','FRB_GW_100s',1,NULL,6,20,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(617,'FRB-GW-10s','FRB_GW_10s',1,NULL,6,20,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(618,'FRB-GW-5s','FRB_GW_5s',1,NULL,6,20,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(619,'FRB-aitoff-e10-e50000-100s','FRB-aitoff-e10-e50000-100s',1,NULL,10,20,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(620,'FRB-aitoff-e10-e50000-10s','FRB-aitoff-e10-e50000-10s',1,NULL,10,20,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(621,'FRB-aitoff-e10-e50000-5s','FRB-aitoff-e10-e50000-5s',1,NULL,10,20,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(622,'FRB_MCAL-PLOT','FRB_MCAL-PLOT',1,NULL,12,20,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(623,'FRB_GRID-UL-100s_FM3.119','FRB_GRID-UL-100s_FM3.119',1,NULL,13,20,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(624,'FRB_GRID-UL-10s_FM3.119','FRB_GRID-UL-10s_FM3.119',1,NULL,13,20,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(625,'FRB_GRID-UL-1000s_FM3.119','FRB_GRID-UL-1000s_FM3.119',1,NULL,13,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(626,'FRB_GRID-UL-5s_FM3.119','FRB_GRID-UL-5s_FM3.119',1,NULL,13,20,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(627,'FRB-GRB-5s_FT3ab','FRB_GRB_5s_FT3ab',1,NULL,16,20,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(628,'FRB-GW-1000s_FT3ab','FRB_GW_1000s_FT3ab',1,NULL,17,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(629,'FRB-GRB-100s_FT3ab','FRB_GRB_100s_FT3ab',1,NULL,16,20,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(630,'FRB-GRB-1000s_FT3ab','FRB_GRB_1000s_FT3ab',1,NULL,16,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(631,'FRB-aitoff-e10-e50000-1000s_FT3ab','FRB-aitoff-e10-e50000-1000s_FT3ab',1,NULL,18,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(632,'FRB-spot6-e10-e50000-1000s_FT3ab','FRB-spot6-e10-e50000-1000s_FT3ab',1,NULL,19,20,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(633,'FRB-GRB-10s_FT3ab','FRB_GRB_10s_FT3ab',1,NULL,16,20,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(634,'FRB-GW-100s_FT3ab','FRB_GW_100s_FT3ab',1,NULL,17,20,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(635,'FRB-GW-10s_FT3ab','FRB_GW_10s_FT3ab',1,NULL,17,20,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(636,'FRB-GW-5s_FT3ab','FRB_GW_5s_FT3ab',1,NULL,17,20,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(637,'FRB-aitoff-e10-e50000-100s_FT3ab','FRB-aitoff-e10-e50000-100s_FT3ab',1,NULL,18,20,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(638,'FRB-aitoff-e10-e50000-10s_FT3ab','FRB-aitoff-e10-e50000-10s_FT3ab',1,NULL,18,20,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(639,'FRB-aitoff-e10-e50000-5s_FT3ab','FRB-aitoff-e10-e50000-5s_FT3ab',1,NULL,18,20,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(640,'FRB_GRID-UL-100s_FT3ab','FRB_GRID-UL-100s_FT3ab',1,NULL,20,20,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(641,'FRB_GRID-UL-10s_FT3ab','FRB_GRID-UL-10s_FT3ab',1,NULL,20,20,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(642,'FRB_GRID-UL-1000s_FT3ab','FRB_GRID-UL-1000s_FT3ab',1,NULL,20,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(643,'FRB_GRID-UL-5s_FT3ab','FRB_GRID-UL-5s_FT3ab',1,NULL,20,20,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(644,'FRB-GRB-5s_lm5','FRB_GRB_5s_lm5',1,NULL,21,20,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(645,'FRB-GW-1000s_lm5','FRB_GW_1000s_lm5',1,NULL,23,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(646,'FRB-GRB-100s_lm5','FRB_GRB_100s_lm5',1,NULL,21,20,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(647,'FRB-GRB-1000s_lm5','FRB_GRB_1000s_lm5',1,NULL,21,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(648,'FRB-GRB-10s_lm5','FRB_GRB_10s_lm5',1,NULL,21,20,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(649,'FRB-GW-100s_lm5','FRB_GW_100s_lm5',1,NULL,23,20,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(650,'FRB-GW-10s_lm5','FRB_GW_10s_lm5',1,NULL,23,20,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(651,'FRB-GW-5s_lm5','FRB_GW_5s_lm5',1,NULL,23,20,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(652,'FRB-GRB-5s_FT3ab_lm5','FRB_GRB_5s_FT3ab_lm5',1,NULL,25,20,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(653,'FRB-GW-1000s_FT3ab_lm5','FRB_GW_1000s_FT3ab_lm5',1,NULL,26,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(654,'FRB-GRB-100s_FT3ab_lm5','FRB_GRB_100s_FT3ab_lm5',1,NULL,25,20,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(655,'FRB-GRB-1000s_FT3ab_lm5','FRB_GRB_1000s_FT3ab_lm5',1,NULL,25,20,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(656,'FRB-GRB-10s_FT3ab_lm5','FRB_GRB_10s_FT3ab_lm5',1,NULL,25,20,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(657,'FRB-GW-100s_FT3ab_lm5','FRB_GW_100s_FT3ab_lm5',1,NULL,26,20,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(658,'FRB-GW-10s_FT3ab_lm5','FRB_GW_10s_FT3ab_lm5',1,NULL,26,20,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(659,'FRB-GW-5s_FT3ab_lm5','FRB_GW_5s_FT3ab_lm5',1,NULL,26,20,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(660,'FRB-FOV','FRB-FOV',1,NULL,15,20,0,4,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(661,'FRB-MCAL-ALERT-partial-coverage','FRB-MCAL-ALERT-partial-coverage',1,NULL,2,20,-1000,1000,2000,0,2000,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(662,'FRB-MCAL-ALERT','FRB-MCAL-ALERT',1,NULL,2,20,-1000,1000,2000,2000,0,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(663,'LIGO_TEST-visCheckAux_v2','LIGO_TEST-visCheckAux_v2',1,NULL,27,18,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(664,'LIGO-visCheckAux_v2','LIGO-visCheckAux_v2',1,NULL,27,1,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(665,'LIGO_TEST-GRID_CIRCULAR','LIGO_TEST-GRID_CIRCULAR',1,NULL,28,18,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,2),
	(666,'Fermi-GBM-GW--2+2s','Fermi-GBM_GW_-2+2s',1,NULL,6,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(667,'Fermi-GBM-GRB--2+2s','Fermi-GBM_GRB_-2+2s',1,NULL,4,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(668,'Swift-GRB--2+2s','Swift_GRB_-2+2s',1,NULL,4,3,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(669,'Fermi-GBM-aitoff-e10-e50000--2+2s','Fermi-GBM-aitoff-e10-e50000--2+2s',1,NULL,10,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(670,'AGILE-MCAL_GW--2+2s','AGILE-MCAL_GW_-2+2s',1,NULL,6,4,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(671,'AGILE-MCAL-aitoff-e10-e50000--2+2s','AGILE-MCAL-aitoff-e10-e50000--2+2s',1,NULL,10,4,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(672,'AGILE-MCAL_GRID-UL--2+2s_FM3.119','AGILE-MCAL_GRID-UL--2+2s_FM3.119',1,NULL,13,4,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(673,'Fermi-GBM_GRID-UL--2+2s_FM3.119','Fermi-GBM_GRID-UL--2+2s_FM3.119',1,NULL,13,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(674,'Swift-aitoff-e10-e50000--2+2s','Swift-aitoff-e10-e50000--2+2s',1,NULL,10,3,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(675,'Swift_GRID-UL--2+2s_FM3.119','Swift_GRID-UL--2+2s_FM3.119',1,NULL,13,3,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(676,'ICECUBE_GOLD-aitoff-e10-e50000--2+2s','ICECUBE_GOLD-aitoff-e10-e50000--2+2s',1,NULL,10,5,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(677,'ICECUBE_GOLD_GRID-UL--2+2s_FM3.119','ICECUBE_GOLD_GRID-UL--2+2s_FM3.119',1,NULL,13,5,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(678,'ICECUBE_GOLD-GRB--2+2s','ICECUBE_GOLD_GRB_-2+2s',1,NULL,4,5,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(679,'ICECUBE_BRONZE-aitoff-e10-e50000--2+2s','ICECUBE_BRONZE-aitoff-e10-e50000--2+2s',1,NULL,10,7,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(680,'ICECUBE_BRONZE_GRID-UL--2+2s_FM3.119','ICECUBE_BRONZE_GRID-UL--2+2s_FM3.119',1,NULL,13,7,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(681,'ICECUBE_BRONZE-GRB--2+2s','ICECUBE_BRONZE_GRB_-2+2s',1,NULL,4,7,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(682,'Fermi-GBM-GW--2+2s_FT3ab','Fermi-GBM_GW_-2+2s_FT3ab',1,NULL,17,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(683,'Fermi-GBM-GRB--2+2s_FT3ab','Fermi-GBM_GRB_-2+2s_FT3ab',1,NULL,16,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(684,'Fermi-GBM-aitoff-e10-e50000--2+2s_FT3ab','Fermi-GBM-aitoff-e10-e50000--2+2s_FT3ab',1,NULL,18,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(685,'Fermi-GBM_GRID-UL--2+2s_FT3ab','Fermi-GBM_GRID-UL--2+2s_FT3ab',1,NULL,20,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(686,'Swift-GRB--2+2s_FT3ab','Swift_GRB_-2+2s_FT3ab',1,NULL,16,3,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(687,'Swift-aitoff-e10-e50000--2+2s_FT3ab','Swift-aitoff-e10-e50000--2+2s_FT3ab',1,NULL,18,3,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(688,'Swift_GRID-UL--2+2s_FT3ab','Swift_GRID-UL--2+2s_FT3ab',1,NULL,20,3,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(689,'AGILE_MCAL-GW--2+2s_FT3ab','AGILE_MCAL_GW_-2+2s_FT3ab',1,NULL,17,4,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(690,'AGILE_MCAL-aitoff-e10-e50000--2+2s_FT3ab','AGILE_MCAL-aitoff-e10-e50000--2+2s_FT3ab',1,NULL,18,4,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(691,'AGILE_MCAL_GRID-UL--2+2s_FT3ab','AGILE_MCAL_GRID-UL--2+2s_FT3ab',1,NULL,20,4,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(692,'ICECUBE_BRONZE-GRB--2+2s_FT3ab','ICECUBE_BRONZE_GRB_-2+2s_FT3ab',1,NULL,16,7,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(693,'ICECUBE_BRONZE-aitoff-e10-e50000--2+2s_FT3ab','ICECUBE_BRONZE-aitoff-e10-e50000--2+2s_FT3ab',1,NULL,18,7,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(694,'ICECUBE_BRONZE_GRID-UL--2+2s_FT3ab','ICECUBE_BRONZE_GRID-UL--2+2s_FT3ab',1,NULL,20,7,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(695,'ICECUBE_GOLD-GRB--2+2s_FT3ab','ICECUBE_GOLD_GRB_-2+2s_FT3ab',1,NULL,16,5,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(696,'ICECUBE_GOLD-aitoff-e10-e50000--2+2s_FT3ab','ICECUBE_GOLD-aitoff-e10-e50000--2+2s_FT3ab',1,NULL,18,5,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(697,'ICECUBE_GOLD_GRID-UL--2+2s_FT3ab','ICECUBE_GOLD_GRID-UL--2+2s_FT3ab',1,NULL,20,5,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(698,'LIGO-GW--2+2s','LIGO_GW_-2+2s',1,NULL,6,1,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(699,'LIGO-aitoff-e10-e50000--2+2s','LIGO-aitoff-e10-e50000--2+2s',1,NULL,10,1,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(700,'LIGO_GRID-UL--2+2s_FM3.119','LIGO_GRID-UL--2+2s_FM3.119',1,NULL,13,1,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(701,'LIGO-GW--2+2s_FT3ab','LIGO_GW_-2+2s_FT3ab',1,NULL,17,1,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(702,'LIGO-aitoff-e10-e50000--2+2s_FT3ab','LIGO-aitoff-e10-e50000--2+2s_FT3ab',1,NULL,18,1,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(703,'LIGO_GRID-UL--2+2s_FT3ab','LIGO_GRID-UL--2+2s_FT3ab',1,NULL,20,1,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(704,'LIGO_TEST-GW--2+2s','LIGO_TEST_GW_-2+2s',1,NULL,6,18,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(705,'LIGO_TEST-aitoff-e10-e50000--2+2s','LIGO_TEST-aitoff-e10-e50000--2+2s',1,NULL,10,18,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(706,'LIGO_TEST_GRID-UL--2+2s_FM3.119','LIGO_TEST_GRID-UL--2+2s_FM3.119',1,NULL,13,18,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(707,'LIGO_TEST-GW--2+2s_FT3ab','LIGO_TEST_GW_-2+2s_FT3ab',1,NULL,17,18,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(708,'LIGO_TEST-aitoff-e10-e50000--2+2s_FT3ab','LIGO_TEST-aitoff-e10-e50000--2+2s_FT3ab',1,NULL,18,18,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(709,'LIGO_TEST_GRID-UL--2+2s_FT3ab','LIGO_TEST_GRID-UL--2+2s_FT3ab',1,NULL,20,18,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(710,'FRB-GW--2+2s','FRB_GW_-2+2s',1,NULL,6,20,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(711,'FRB-GRB--2+2s','FRB_GRB_-2+2s',1,NULL,4,20,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(712,'FRB-aitoff-e10-e50000--2+2s','FRB-aitoff-e10-e50000--2+2s',1,NULL,10,20,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(713,'FRB_GRID-UL--2+2s_FM3.119','FRB_GRID-UL--2+2s_FM3.119',1,NULL,13,20,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(714,'FRB-GW--2+2s_FT3ab','FRB_GW_-2+2s_FT3ab',1,NULL,17,20,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(715,'FRB-GRB--2+2s_FT3ab','FRB_GRB_-2+2s_FT3ab',1,NULL,16,20,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(716,'FRB-aitoff-e10-e50000--2+2s_FT3ab','FRB-aitoff-e10-e50000--2+2s_FT3ab',1,NULL,18,20,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(717,'FRB_GRID-UL--2+2s_FT3ab','FRB_GRID-UL--2+2s_FT3ab',1,NULL,20,20,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(718,'FRB-GRB--2+2s_lm5','FRB_GRB_-2+2s_lm5',1,NULL,21,20,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(719,'FRB-GRB--2+2s_FT3ab_lm5','FRB_GRB_-2+2s_FT3ab_lm5',1,NULL,25,20,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(720,'LIGO-GRID_CIRCULAR','LIGO-GRID_CIRCULAR',1,NULL,28,1,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,2),
	(721,'Fermi-LAT_MCAL-ALERT','Fermi-LAT_mcal_alert_full',1,NULL,2,21,-1000,1000,2000,2000,0,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(722,'Fermi-LAT_MCAL-ALERT-partial-coverage','Fermi-LAT_mcal_alert_partial',1,NULL,2,21,-1000,1000,2000,0,2000,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(723,'Fermi-LAT-GRB-5s','Fermi-LAT_GRB_5s',1,NULL,4,21,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(724,'Fermi-LAT-GW-1000s','Fermi-LAT_GW_1000s',1,NULL,6,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(725,'Fermi-LAT-GRB-100s','Fermi-LAT_GRB_100s',1,NULL,4,21,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(726,'Fermi-LAT-GRB-1000s','Fermi-LAT_GRB_1000s',1,NULL,4,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(727,'Fermi-LAT-visCheckAux','Fermi-LAT-visCheckAux',1,NULL,7,21,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(728,'Fermi-LAT-ratemeters','Fermi-LAT-ratemeters',1,NULL,8,21,-500,500,1000,1000,0,1000,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(729,'Fermi-LAT-ATstatus','Fermi-LAT-ATstatus',1,NULL,9,21,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(730,'Fermi-LAT-aitoff-e10-e50000-1000s','Fermi-LAT-aitoff-e10-e50000-1000s',1,NULL,10,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(731,'Fermi-LAT-spot6-e10-e50000-1000s','Fermi-LAT-spot6-e10-e50000-1000s',1,NULL,11,21,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(732,'Fermi-LAT-GRB-10s','Fermi-LAT_GRB_10s',1,NULL,4,21,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(733,'Fermi-LAT-GW-100s','Fermi-LAT_GW_100s',1,NULL,6,21,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(734,'Fermi-LAT-GW-10s','Fermi-LAT_GW_10s',1,NULL,6,21,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(735,'Fermi-LAT-GW-5s','Fermi-LAT_GW_5s',1,NULL,6,21,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(736,'Fermi-LAT-aitoff-e10-e50000-100s','Fermi-LAT-aitoff-e10-e50000-100s',1,NULL,10,21,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(737,'Fermi-LAT-aitoff-e10-e50000-10s','Fermi-LAT-aitoff-e10-e50000-10s',1,NULL,10,21,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(738,'Fermi-LAT-aitoff-e10-e50000-5s','Fermi-LAT-aitoff-e10-e50000-5s',1,NULL,10,21,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(739,'Fermi-LAT_MCAL-PLOT','Fermi-LAT_MCAL-PLOT',1,NULL,12,21,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(740,'Fermi-LAT_GRID-UL-100s_FM3.119','Fermi-LAT_GRID-UL-100s_FM3.119',1,NULL,13,21,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(741,'Fermi-LAT_GRID-UL-10s_FM3.119','Fermi-LAT_GRID-UL-10s_FM3.119',1,NULL,13,21,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(742,'Fermi-LAT_GRID-UL-1000s_FM3.119','Fermi-LAT_GRID-UL-1000s_FM3.119',1,NULL,13,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(743,'Fermi-LAT_GRID-UL-5s_FM3.119','Fermi-LAT_GRID-UL-5s_FM3.119',1,NULL,13,21,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(744,'Fermi-LAT-FOV','Fermi-LAT-FOV',1,NULL,15,21,0,4,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(745,'Fermi-LAT-GRB-5s_FT3ab','Fermi-LAT_GRB_5s_FT3ab',1,NULL,16,21,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(746,'Fermi-LAT-GW-1000s_FT3ab','Fermi-LAT_GW_1000s_FT3ab',1,NULL,17,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(747,'Fermi-LAT-GRB-100s_FT3ab','Fermi-LAT_GRB_100s_FT3ab',1,NULL,16,21,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(748,'Fermi-LAT-GRB-1000s_FT3ab','Fermi-LAT_GRB_1000s_FT3ab',1,NULL,16,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(749,'Fermi-LAT-aitoff-e10-e50000-1000s_FT3ab','Fermi-LAT-aitoff-e10-e50000-1000s_FT3ab',1,NULL,18,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(750,'Fermi-LAT-spot6-e10-e50000-1000s_FT3ab','Fermi-LAT-spot6-e10-e50000-1000s_FT3ab',1,NULL,19,21,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(751,'Fermi-LAT-GRB-10s_FT3ab','Fermi-LAT_GRB_10s_FT3ab',1,NULL,16,21,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(752,'Fermi-LAT-GW-100s_FT3ab','Fermi-LAT_GW_100s_FT3ab',1,NULL,17,21,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(753,'Fermi-LAT-GW-10s_FT3ab','Fermi-LAT_GW_10s_FT3ab',1,NULL,17,21,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(754,'Fermi-LAT-GW-5s_FT3ab','Fermi-LAT_GW_5s_FT3ab',1,NULL,17,21,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(755,'Fermi-LAT-aitoff-e10-e50000-100s_FT3ab','Fermi-LAT-aitoff-e10-e50000-100s_FT3ab',1,NULL,18,21,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(756,'Fermi-LAT-aitoff-e10-e50000-10s_FT3ab','Fermi-LAT-aitoff-e10-e50000-10s_FT3ab',1,NULL,18,21,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(757,'Fermi-LAT-aitoff-e10-e50000-5s_FT3ab','Fermi-LAT-aitoff-e10-e50000-5s_FT3ab',1,NULL,18,21,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(758,'Fermi-LAT_GRID-UL-100s_FT3ab','Fermi-LAT_GRID-UL-100s_FT3ab',1,NULL,20,21,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(759,'Fermi-LAT_GRID-UL-10s_FT3ab','Fermi-LAT_GRID-UL-10s_FT3ab',1,NULL,20,21,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(760,'Fermi-LAT_GRID-UL-1000s_FT3ab','Fermi-LAT_GRID-UL-1000s_FT3ab',1,NULL,20,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(761,'Fermi-LAT_GRID-UL-5s_FT3ab','Fermi-LAT_GRID-UL-5s_FT3ab',1,NULL,20,21,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(762,'Fermi-LAT-GRB-5s_lm5','Fermi-LAT_GRB_5s_lm5',1,NULL,21,21,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(763,'Fermi-LAT-GW-1000s_lm5','Fermi-LAT_GW_1000s_lm5',1,NULL,23,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(764,'Fermi-LAT-GRB-100s_lm5','Fermi-LAT_GRB_100s_lm5',1,NULL,21,21,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(765,'Fermi-LAT-GRB-1000s_lm5','Fermi-LAT_GRB_1000s_lm5',1,NULL,21,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(766,'Fermi-LAT-GRB-10s_lm5','Fermi-LAT_GRB_10s_lm5',1,NULL,21,21,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(767,'Fermi-LAT-GW-100s_lm5','Fermi-LAT_GW_100s_lm5',1,NULL,23,21,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(768,'Fermi-LAT-GW-10s_lm5','Fermi-LAT_GW_10s_lm5',1,NULL,23,21,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(769,'Fermi-LAT-GW-5s_lm5','Fermi-LAT_GW_5s_lm5',1,NULL,23,21,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(770,'Fermi-LAT-GRB-5s_FT3ab_lm5','Fermi-LAT_GRB_5s_FT3ab_lm5',1,NULL,25,21,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(771,'Fermi-LAT-GW-1000s_FT3ab_lm5','Fermi-LAT_GW_1000s_FT3ab_lm5',1,NULL,26,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(772,'Fermi-LAT-GRB-100s_FT3ab_lm5','Fermi-LAT_GRB_100s_FT3ab_lm5',1,NULL,25,21,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(773,'Fermi-LAT-GRB-1000s_FT3ab_lm5','Fermi-LAT_GRB_1000s_FT3ab_lm5',1,NULL,25,21,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(774,'Fermi-LAT-GRB-10s_FT3ab_lm5','Fermi-LAT_GRB_10s_FT3ab_lm5',1,NULL,25,21,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(775,'Fermi-LAT-GW-100s_FT3ab_lm5','Fermi-LAT_GW_100s_FT3ab_lm5',1,NULL,26,21,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(776,'Fermi-LAT-GW-10s_FT3ab_lm5','Fermi-LAT_GW_10s_FT3ab_lm5',1,NULL,26,21,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(777,'Fermi-LAT-GW-5s_FT3ab_lm5','Fermi-LAT_GW_5s_FT3ab_lm5',1,NULL,26,21,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(778,'Fermi-LAT-GW--2+2s','Fermi-LAT_GW_-2+2s',1,NULL,6,21,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(779,'Fermi-LAT-GRB--2+2s','Fermi-LAT_GRB_-2+2s',1,NULL,4,21,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(780,'Fermi-LAT-aitoff-e10-e50000--2+2s','Fermi-LAT-aitoff-e10-e50000--2+2s',1,NULL,10,21,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(781,'Fermi-LAT_GRID-UL--2+2s_FM3.119','Fermi-LAT_GRID-UL--2+2s_FM3.119',1,NULL,13,21,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(782,'Fermi-LAT-GW--2+2s_FT3ab','Fermi-LAT_GW_-2+2s_FT3ab',1,NULL,17,21,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(783,'Fermi-LAT-GRB--2+2s_FT3ab','Fermi-LAT_GRB_-2+2s_FT3ab',1,NULL,16,21,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(784,'Fermi-LAT-aitoff-e10-e50000--2+2s_FT3ab','Fermi-LAT-aitoff-e10-e50000--2+2s_FT3ab',1,NULL,18,21,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(785,'Fermi-LAT_GRID-UL--2+2s_FT3ab','Fermi-LAT_GRID-UL--2+2s_FT3ab',1,NULL,20,21,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0);

/*!40000 ALTER TABLE `analysissessiontype` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table analysissessiontype_notice
# ------------------------------------------------------------

DROP TABLE IF EXISTS `analysissessiontype_notice`;

CREATE TABLE `analysissessiontype_notice` (
  `analysissessiontype_noticeid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `analysissessiontypeid` int(10) unsigned NOT NULL,
  `noticeid` int(10) unsigned NOT NULL,
  `tstart` double DEFAULT NULL,
  `tstop` double DEFAULT NULL,
  PRIMARY KEY (`analysissessiontype_noticeid`),
  UNIQUE KEY `analysissessiontypeid_2` (`analysissessiontypeid`,`noticeid`),
  KEY `analysissessiontypeid` (`analysissessiontypeid`),
  KEY `noticeid` (`noticeid`),
  CONSTRAINT `analysissessiontype_notice_ibfk_1` FOREIGN KEY (`analysissessiontypeid`) REFERENCES `analysissessiontype` (`analysissessiontypeid`) ON DELETE CASCADE,
  CONSTRAINT `analysissessiontype_notice_ibfk_2` FOREIGN KEY (`noticeid`) REFERENCES `notice` (`noticeid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`188.15.168.50` */ /*!50003 TRIGGER `analysissessiotype_notice_insert` AFTER INSERT ON `analysissessiontype_notice` FOR EACH ROW trigger_label: BEGIN


        DECLARE dr_tstart DOUBLE;
		DECLARE dr_tstop DOUBLE;
        DECLARE obs_id DOUBLE;

		DECLARE done INT DEFAULT FALSE;

		DECLARE cur1 CURSOR FOR SELECT otdr.tstartdata,otdr.tenddata,otdr.observationid FROM observation_to_datarepository otdr join observation obs ON (obs.observationid = otdr.observationid) join datarepository dr on (dr.datarepositoryid = otdr.datarepositoryid) JOIN  dataprocessingtool_datatype_input dptd
        ON (dptd.datatypeid = dr.datatypeid) JOIN analysistype ant ON (ant.dataprocessingtoolid = dptd.dataprocessingtoolid) JOIN analysissessiontype anst ON (anst.analysistypeid = ant.analysistypeid) WHERE
        anst.analysissessiontypeid = NEW.analysissessiontypeid AND  dr.active=1 AND dptd.type = 1 AND obs.status = 1;

		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		OPEN cur1;

		

		read_loop: LOOP

			FETCH cur1 INTO dr_tstart,dr_tstop,obs_id;

            IF done THEN
				LEAVE read_loop;
			END IF;


			INSERT INTO log SELECT now(), concat('check datarepository ', dr_tstart,' ',dr_tstop,' for notice ',NEW.tstart,' ',NEW.tstop);

            IF dr_tstart <= NEW.tstop AND dr_tstop >= NEW.tstart THEN

				INSERT INTO log SELECT now(), concat('observation for notice ', obs_id);

                INSERT INTO analysissessiontype_notice_observation (analysissessiontype_noticeid,observationid,active) VALUES (NEW.analysissessiontype_noticeid,obs_id,1);

            END IF;


		END LOOP;

		CLOSE cur1;


END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# Dump of table analysissessiontype_notice_observation
# ------------------------------------------------------------

DROP TABLE IF EXISTS `analysissessiontype_notice_observation`;

CREATE TABLE `analysissessiontype_notice_observation` (
  `analysissessiontype_notice_observationid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `analysissessiontype_noticeid` int(10) unsigned NOT NULL,
  `observationid` int(10) unsigned NOT NULL,
  `active` int(11) DEFAULT NULL,
  PRIMARY KEY (`analysissessiontype_notice_observationid`),
  UNIQUE KEY `analysissessiontype_noticeid` (`analysissessiontype_noticeid`,`observationid`) USING BTREE,
  KEY `observationid` (`observationid`),
  KEY `analysissessiontype_noticeid_2` (`analysissessiontype_noticeid`),
  CONSTRAINT `analysissessiontype_notice_observation_ibfk_4` FOREIGN KEY (`observationid`) REFERENCES `observation` (`observationid`) ON UPDATE CASCADE,
  CONSTRAINT `analysissessiontype_notice_observation_ibfk_5` FOREIGN KEY (`analysissessiontype_noticeid`) REFERENCES `analysissessiontype_notice` (`analysissessiontype_noticeid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`%` */ /*!50003 TRIGGER `analysissessiontype_notice_observation_insert` AFTER INSERT ON `analysissessiontype_notice_observation` FOR EACH ROW trigger_label: BEGIN


            DECLARE dr_tstart DOUBLE;
            DECLARE dr_tstop DOUBLE;
            DECLARE notice_analysis_tstart DOUBLE;
            DECLARE notice_analysis_tstop DOUBLE;
            DECLARE time_start_run DOUBLE;
            DECLARE time_stop_run DOUBLE;
            DECLARE time_bin_size DOUBLE;
            DECLARE time_step DOUBLE;
            DECLARE min_bin_size DOUBLE;
            DECLARE max_bin_size DOUBLE;
			DECLARE skyposition_type INT;
			DECLARE energybingroup_id INT UNSIGNED;
			DECLARE skyringgroup_id INT UNSIGNED;
			DECLARE basedir_results BLOB;
			DECLARE basedir_run BLOB;
			DECLARE instrument_name VARCHAR(128);
			DECLARE datarepository_name VARCHAR(255);
			DECLARE analysissessiontype_shortname VARCHAR(255);
			DECLARE analysistype_shortname VARCHAR(255);
			DECLARE analysis_session_dir VARCHAR(255);
			DECLARE run_dir VARCHAR(255);
			DECLARE good_time_window BOOLEAN;
            DECLARE aggregation_id INT;
            DECLARE run_status INT;
            DECLARE analysissession_id INT UNSIGNED;
            DECLARE trigger_id BIGINT;
            DECLARE seq_num INT;
            DECLARE max_tstart_all DOUBLE;
            DECLARE min_tstop_all DOUBLE;
            DECLARE analysissessiontype_id INT UNSIGNED;
			DECLARE analysis_radius DOUBLE;
            DECLARE notice_l DOUBLE;
            DECLARE notice_b DOUBLE;


			
            SELECT seqnum,triggerid,instr.name INTO seq_num,trigger_id,instrument_name FROM receivedsciencealert rsa JOIN instrument instr ON (instr.instrumentid = rsa.instrumentid) JOIN notice n on (n.receivedsciencealertid = rsa.receivedsciencealertid) JOIN analysissessiontype_notice anstn ON (anstn.noticeid = n.noticeid) WHERE anstn.analysissessiontype_noticeid = NEW.analysissessiontype_noticeid;


			    

            SELECT  n.l as 'notice_l',n.b as 'notice_b',anst.analysissessiontypeid,tstartdata,tenddata,anst.timebinsize,anst.minbinsize,anst.maxbinsize,anst.timestep,anst.skypositiontype,anst.energybingroupid,anst.skyringgroupid,anst.shortname,ant.shortname,dr.name,atr.basedirresults,atr.basedirrun,anst.aggregation,anst.analysisradius

            INTO notice_l,notice_b,analysissessiontype_id,dr_tstart,dr_tstop,time_bin_size,min_bin_size,max_bin_size,time_step,skyposition_type,energybingroup_id,skyringgroup_id, analysissessiontype_shortname,analysistype_shortname,datarepository_name,basedir_results,basedir_run,aggregation_id,analysis_radius
            FROM observation_to_datarepository otd JOIN datarepository dr ON (otd.datarepositoryid = dr.datarepositoryid) join dataprocessingtool_datatype_input dptdt
            on (dr.datatypeid = dptdt.datatypeid) join analysistype ant on (ant.dataprocessingtoolid = dptdt.dataprocessingtoolid) join analysissessiontype anst on (anst.analysistypeid = ant.analysistypeid) join analysissessiontype_notice anstn
            on (anstn.analysissessiontypeid = anst.analysissessiontypeid ) join notice n ON (n.noticeid = anstn.noticeid)  join analysistrigger atr on (atr.analysistriggerid = anst.analysistriggerid) WHERE anst.runnable = 1 and dptdt.type = 1 AND anstn.analysissessiontype_noticeid = NEW.analysissessiontype_noticeid  AND observationid = NEW.observationid;

			SELECT tstart,tstop INTO notice_analysis_tstart,notice_analysis_tstop FROM analysissessiontype_notice WHERE analysissessiontype_noticeid = NEW.analysissessiontype_noticeid;

			SET time_start_run  = notice_analysis_tstart ;
            SET time_stop_run  = time_start_run+time_bin_size;

            

            
			

			BEGIN

				DECLARE done2 INT DEFAULT FALSE;
				DECLARE datarepository_id INT UNSIGNED;

				DECLARE tstart_st_repository DOUBLE;
				DECLARE tstop_st_repository DOUBLE;

                DECLARE analysissessiontype_observation_tstop DOUBLE;

				DECLARE cur2 CURSOR FOR SELECT dr.datarepositoryid from datarepository dr join dataprocessingtool_datatype_input dpt  on (dr.datatypeid = dpt.datatypeid ) join analysistype ant on(dpt.dataprocessingtoolid = ant.dataprocessingtoolid) join analysissessiontype ast on(ast.analysistypeid = ant.analysistypeid )
				WHERE analysissessiontypeid = analysissessiontype_id and dr.active=1 and dpt.required = 1 ;
				DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;

                SET max_tstart_all = 0;
                SET min_tstop_all = 100000000000;

				OPEN cur2;
				
				read_loop2: LOOP

					FETCH cur2 INTO datarepository_id;

					IF done2 THEN
						LEAVE read_loop2;
					END IF;

					SELECT otd.tstartdata,otd.tenddata INTO tstart_st_repository,tstop_st_repository   FROM observation_to_datarepository otd WHERE otd.observationid = NEW.observationid AND datarepositoryid = datarepository_id;

					IF tstart_st_repository > max_tstart_all THEN

                        SET max_tstart_all = tstart_st_repository;

                    END IF;

                    IF tstop_st_repository < min_tstop_all THEN

                        SET min_tstop_all = tstop_st_repository;

                    END IF;

				END LOOP;

				CLOSE cur2;
            END;

			

            create_run: WHILE time_stop_run <= notice_analysis_tstop DO


				

                

                SET good_time_window = TRUE;

                BEGIN


					DECLARE done3 INT DEFAULT FALSE;

                    DECLARE tstart_tw DOUBLE;
                    DECLARE tstop_tw DOUBLE;

					DECLARE cur3 CURSOR FOR SELECT tstart,tstop FROM observationwindowstatus WHERE observationid = NEW.observationid AND status = 0;
					DECLARE CONTINUE HANDLER FOR NOT FOUND SET done3 = TRUE;


					OPEN cur3;

					
					read_loop3: LOOP

						FETCH cur3 INTO tstart_tw,tstop_tw;

						IF done3 THEN
							LEAVE read_loop3;
						END IF;


                        
                        IF tstop_tw >= time_start_run AND tstart_tw <= time_start_run +min_bin_size THEN

							SET good_time_window = FALSE;

                        END IF;


					END LOOP;

					CLOSE cur3;


				END;

               

               

					

					
						
							
							



                    IF  aggregation_id = 1 THEN

						SET analysis_session_dir = concat(basedir_results,instrument_name,'-alert','/TR',trigger_id,'_S',seq_num,'/'); 

						
						INSERT INTO analysissession (analysissessiontype_notice_observationid,tstart,tstop,status,diroutputresults,type) VALUES (NEW.analysissessiontype_notice_observationid,time_start_run,time_stop_run,0,analysis_session_dir,1);

                        SET analysissession_id = LAST_INSERT_ID();

						

                        BEGIN

							DECLARE done4 INT DEFAULT FALSE;
                            DECLARE energybin_id INT UNSIGNED;
                            DECLARE b_obs DOUBLE;
                            DECLARE l_obs DOUBLE;
                            DECLARE e_min DOUBLE;
                            DECLARE e_max DOUBLE;

							DECLARE cur4 CURSOR FOR SELECT eb.energybinid FROM energybin eb WHERE eb.energybingroupid = energybingroup_id;
							DECLARE CONTINUE HANDLER FOR NOT FOUND SET done4 = TRUE;


							OPEN cur4;

							
							read_loop4: LOOP

								FETCH cur4 INTO energybin_id;


								IF done4 THEN
									LEAVE read_loop4;
								END IF;


								SELECT emin,emax INTO e_min,e_max FROM energybin WHERE energybinid = energybin_id;



                                
								IF skyposition_type = 1 THEN


									SELECT l,b INTO l_obs,b_obs FROM observation where observationid = NEW.observationid;

									SET run_status = 2;
                    
										
										
									IF good_time_window IS FALSE THEN
										SET run_status = 1;
									END IF;

                                    IF time_start_run + min_bin_size > min_tstop_all OR time_start_run < max_tstart_all THEN
										SET run_status = 1;
									END IF;

									IF max_bin_size > 0 AND min_tstop_all >=  time_start_run + max_bin_size THEN
										SET run_status = -3;
									END IF;


									SET run_dir = concat(basedir_run,instrument_name,'-alert','/TR',trigger_id,'_S',seq_num,'/',analysistype_shortname,'_',analysissessiontype_shortname,'/T',time_start_run,'_',time_stop_run,'_E',e_min,'_',e_max,'_P',l_obs,'_',b_obs,'/');

									
									INSERT INTO run (analysissessionid,tstart,tstop,status,l,b,r,energybinid,diroutputrun) VALUES (analysissession_id,time_start_run,time_stop_run,run_status,l_obs,b_obs,analysis_radius,energybin_id,run_dir);



                                END IF;

							   
								IF skyposition_type = 4 THEN


									SET run_status = 2;
                  
										
										
									IF good_time_window IS FALSE THEN
										SET run_status = 1;
									END IF;

                                    IF time_start_run + min_bin_size > min_tstop_all OR time_start_run < max_tstart_all THEN
										SET run_status = 1;
									END IF;

									IF max_bin_size > 0 AND min_tstop_all >=  time_start_run + max_bin_size THEN
										SET run_status = -3;
									END IF;


									SET run_dir = concat(basedir_run,instrument_name,'-alert','/TR',trigger_id,'_S',seq_num,'/',analysistype_shortname,'_',analysissessiontype_shortname,'/T',time_start_run,'_',time_stop_run,'_E',e_min,'_',e_max,'_P',notice_l,'_',notice_b,'/');

									
									INSERT INTO run (analysissessionid,tstart,tstop,status,l,b,r,energybinid,diroutputrun) VALUES (analysissession_id,time_start_run,time_stop_run,run_status,notice_l,notice_b,analysis_radius,energybin_id,run_dir);



                                END IF;

								
								IF skyposition_type = 10 THEN



									BEGIN

										DECLARE done5 INT DEFAULT FALSE;
										DECLARE skyring_id INT UNSIGNED;
                                        DECLARE ring_b DOUBLE;
                                        DECLARE ring_l DOUBLE;
                                        DECLARE ring_radius DOUBLE;


										DECLARE cur5 CURSOR FOR SELECT sr.skyringid,sr.l,sr.b,sr.r FROM skyring sr WHERE sr.skyringgroupid = skyringgroup_id;
										DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5 = TRUE;

										OPEN cur5;

										
										read_loop5: LOOP

											FETCH cur5 INTO skyring_id,ring_l,ring_b,ring_radius;

											IF done5 THEN
												LEAVE read_loop5;
											END IF;

                                            SET run_status = 2;
											
												
												
											IF good_time_window IS FALSE THEN
												SET run_status = 1;
											END IF;

											IF time_start_run + min_bin_size > min_tstop_all OR time_start_run < max_tstart_all THEN
												SET run_status = 1;
											END IF;

											IF max_bin_size > 0 AND min_tstop_all >= time_start_run + max_bin_size THEN
												SET run_status = -3;
											END IF;



											SET run_dir = concat(basedir_run,instrument_name,'-alert','/TR',trigger_id,'_S',seq_num,'/',analysistype_shortname,'_',analysissessiontype_shortname,'/T',time_start_run,'_',time_stop_run,'_E',e_min,'_',e_max,'_P',ring_l,'_',ring_b,'/');

                                            
                                            INSERT INTO run (analysissessionid,tstart,tstop,status,skyringid,energybinid,diroutputrun,l,b,r) VALUES (analysissession_id,time_start_run,time_stop_run,run_status,skyring_id,energybin_id,run_dir,ring_l,ring_b,analysis_radius);


										END LOOP;

										CLOSE cur5;

                                    END; 

                                END IF; 



							END LOOP;

							CLOSE cur4;

						END; 


					END IF; 

                

                

				SET time_start_run = time_start_run + time_step;
				SET time_stop_run = time_start_run + time_bin_size;

            

				

            END WHILE;



END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# Dump of table analysissessiontype_observation
# ------------------------------------------------------------

DROP TABLE IF EXISTS `analysissessiontype_observation`;

CREATE TABLE `analysissessiontype_observation` (
  `analysissessiontype_observationid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `analysissessiontypeid` int(10) unsigned NOT NULL,
  `observationid` int(10) unsigned NOT NULL,
  `tstartlastrun` double NOT NULL,
  `tstoplastrun` double DEFAULT NULL,
  PRIMARY KEY (`analysissessiontype_observationid`),
  UNIQUE KEY `index4` (`analysissessiontypeid`,`observationid`),
  KEY `analysissessiontypeid` (`analysissessiontypeid`),
  KEY `observationid` (`observationid`),
  CONSTRAINT `analysissessiontype_observation_ibfk_1` FOREIGN KEY (`analysissessiontypeid`) REFERENCES `analysissessiontype` (`analysissessiontypeid`) ON DELETE CASCADE,
  CONSTRAINT `analysissessiontype_observation_ibfk_2` FOREIGN KEY (`observationid`) REFERENCES `observation` (`observationid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table analysissessiontype_sequence
# ------------------------------------------------------------

DROP TABLE IF EXISTS `analysissessiontype_sequence`;

CREATE TABLE `analysissessiontype_sequence` (
  `child_analysissessiontypeid` int(11) unsigned NOT NULL,
  `parent_analysissessiontypeid` int(11) unsigned NOT NULL,
  PRIMARY KEY (`child_analysissessiontypeid`,`parent_analysissessiontypeid`),
  KEY `parent_analysissessiontypeid` (`parent_analysissessiontypeid`),
  CONSTRAINT `analysissessiontype_sequence_ibfk_1` FOREIGN KEY (`child_analysissessiontypeid`) REFERENCES `analysissessiontype` (`analysissessiontypeid`),
  CONSTRAINT `analysissessiontype_sequence_ibfk_2` FOREIGN KEY (`parent_analysissessiontypeid`) REFERENCES `analysissessiontype` (`analysissessiontypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table analysistrigger
# ------------------------------------------------------------

DROP TABLE IF EXISTS `analysistrigger`;

CREATE TABLE `analysistrigger` (
  `analysistriggerid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(128) NOT NULL,
  `shortname` char(15) NOT NULL,
  `category` int(11) NOT NULL,
  `triggersourcedatarepositoryid` int(10) unsigned DEFAULT NULL,
  `triggersourcedatarepositoryidinstrumentid` int(10) unsigned DEFAULT NULL,
  `triggersourcesciencealertinstrumentid` int(10) unsigned DEFAULT NULL,
  `basedirresults` text NOT NULL,
  `basedirrun` text NOT NULL,
  `status` int(11) NOT NULL,
  PRIMARY KEY (`analysistriggerid`),
  UNIQUE KEY `shortname` (`shortname`),
  UNIQUE KEY `index6` (`triggersourcedatarepositoryidinstrumentid`,`triggersourcedatarepositoryid`),
  UNIQUE KEY `index7` (`triggersourcesciencealertinstrumentid`),
  KEY `triggersourcedatarepositoryid` (`triggersourcedatarepositoryid`),
  KEY `triggersourcedatarepositoryidinstrumentid` (`triggersourcedatarepositoryidinstrumentid`),
  KEY `triggersourcesciencealertinstrumentid` (`triggersourcesciencealertinstrumentid`),
  CONSTRAINT `analysistrigger_ibfk_1` FOREIGN KEY (`triggersourcedatarepositoryidinstrumentid`) REFERENCES `instrument` (`instrumentid`) ON UPDATE CASCADE,
  CONSTRAINT `analysistrigger_ibfk_2` FOREIGN KEY (`triggersourcesciencealertinstrumentid`) REFERENCES `instrument` (`instrumentid`) ON UPDATE CASCADE,
  CONSTRAINT `analysistriggeribfk1` FOREIGN KEY (`triggersourcedatarepositoryid`) REFERENCES `datarepository` (`datarepositoryid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `analysistrigger` WRITE;
/*!40000 ALTER TABLE `analysistrigger` DISABLE KEYS */;

INSERT INTO `analysistrigger` (`analysistriggerid`, `name`, `shortname`, `category`, `triggersourcedatarepositoryid`, `triggersourcedatarepositoryidinstrumentid`, `triggersourcesciencealertinstrumentid`, `basedirresults`, `basedirrun`, `status`)
VALUES
	(1,'LIGO_GW','LIGO_GW',0,NULL,NULL,7,'/ANALYSIS3/','/ANALYSIS3/RUN/',0),
	(2,'FERMI_GBM','FERMI_GBM',0,NULL,NULL,1,'/ANALYSIS3/','/ANALYSIS3/RUN/',0),
	(3,'Swift','Swift',0,NULL,NULL,3,'/ANALYSIS3/','/ANALYSIS3/RUN/',0),
	(4,'AGILE_MCAL','AGILE_MCAL',0,NULL,NULL,5,'/ANALYSIS3/','/ANALYSIS3/RUN/',0),
	(5,'ICECUBE_GOLD','ICECUBE_GOLD',0,NULL,NULL,21,'/ANALYSIS3/','/ANALYSIS3/RUN/',0),
	(7,'ICECUBE_BRONZE','ICECUBE_BRONZE',0,NULL,NULL,22,'/ANALYSIS3/','/ANALYSIS3/RUN/',0),
	(8,'AGILE_MCAL_AU','AGILE_MCAL_AU',0,NULL,NULL,17,'/ANALYSIS3/','/ANALYSIS3/RUN/',0),
	(18,'LIGO_TEST','LIGO_TEST',0,NULL,NULL,19,'/ANALYSIS3/','/ANALYSIS3/RUN/',0),
	(20,'FRB','FRB',0,NULL,NULL,20,'/ANALYSIS3/','/ANALYSIS3/RUN/',0),
	(21,'FERMI_LAT','FERMI_LAT',0,NULL,NULL,2,'/ANALYSIS3/','/ANALYSIS3/RUN/',0);

/*!40000 ALTER TABLE `analysistrigger` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table analysistype
# ------------------------------------------------------------

DROP TABLE IF EXISTS `analysistype`;

CREATE TABLE `analysistype` (
  `analysistypeid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL DEFAULT '',
  `shortname` varchar(100) NOT NULL DEFAULT '',
  `description` blob,
  `dataprocessingtoolid` int(10) unsigned NOT NULL,
  `intervaltype` int(11) DEFAULT NULL,
  `metaconffile` text,
  `task` text,
  `deleterun` tinyint(1) NOT NULL,
  PRIMARY KEY (`analysistypeid`),
  UNIQUE KEY `shortname` (`shortname`),
  KEY `sciencetoolid` (`dataprocessingtoolid`),
  CONSTRAINT `analysistypeibfk1` FOREIGN KEY (`dataprocessingtoolid`) REFERENCES `dataprocessingtool` (`dataprocessingtoolid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `analysistype` WRITE;
/*!40000 ALTER TABLE `analysistype` DISABLE KEYS */;

INSERT INTO `analysistype` (`analysistypeid`, `name`, `shortname`, `description`, `dataprocessingtoolid`, `intervaltype`, `metaconffile`, `task`, `deleterun`)
VALUES
	(2,'MCAL Alert','MCAL_alert',NULL,2,NULL,'<run id=\"#@runid@#\">\n         <parameter name=\"AlertInfo\" triggerid=\"#@triggerid@#\" seqnum=\"#@seqnum@#\" contname=\"#@contour_name@#\" notice_type=\"#@notice_type@#\" />\n	<parameter name=\"TimeIntervals\" tmin=\"#@tstart@#\" tmax=\"#@tstop@#\" t0=\"#@tzero@#\" timeunit=\"#@timerefunit@#\" timesys=\"#@timerefname@#\"/>\n        <parameter name=\"Energy\" emin=\"#@emin@#\" emax=\"#@emax@#\" energyBinID=\"\" />\n	<parameter name=\"DirectoryList\" run=\"#@diroutputrun@#\" results=\"#@diroutputresults@#\" runprefix=\"#@runprefix@#\" fitspath=\"/data01/ASDC_PROC2/DATA_2/COR/\" />\n         <parameter name=\"DeleteRun\" value=\"0\" />\n</run>','python $MCALPIPE/MCAL-ALERT.py run.xml',0),
	(4,'GRB_FM3.119','GRB_FM3.119',NULL,3,NULL,'GRB\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputresults@#\n#@diroutputrun@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@n_radius@#\n10\n#@tzero@#\n#@tstart@#\n#@tstop@#\n500\n600\n70\n75\n0\nFM3.119\ngrb_pipe\n----\n#@contour@#\n','date\n$AGILEPIPE/grb_gw/grb_gw_new.py run.xml\n',0),
	(6,'GW_FM3.119','GW_FM3.119',NULL,3,NULL,'GW\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputresults@#\n#@diroutputrun@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@n_radius@#\n10\n#@tzero@#\n#@tstart@#\n#@tstop@#\n500\n600\n70\n75\n0\nFM3.119\ngrb_pipe\n----\n#@contour@#\n','date\n$AGILEPIPE/grb_gw/grb_gw_new.py run.xml\n',0),
	(7,'visCheckAux','visCheckAux',NULL,6,NULL,'visCheckAux\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputrun@#\n#@diroutputresults@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@radius@#\n#@tzero@#\n#@tstart@#\n#@tstop@#\n70\n80\n----\n#@contour@#','date\n$AGILEPIPE/visCheck/burst_position.sh run.xml\n',0),
	(8,'ratemeters','ratemeters',NULL,7,NULL,'Ratemeters\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputrun@#\n#@diroutputresults@#\n#@ant_sname@#\n#@anst_sname@#\n#@tzero@#\n#@tstart@#\n#@tstop@#\n','date\n$AGILEPIPE/ratemeters/ratemeters_pipe.sh run.xml',0),
	(9,'ATstatus','ATstatus',NULL,9,NULL,'ATstatus\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputrun@#\n#@diroutputresults@#\n#@ant_sname@#\n#@anst_sname@#\n#@tzero@#\n#@tstart@#\n#@tstop@#\n','date\npython $AGILEPIPE/ATstatus/get_status.py run.xml',0),
	(10,'GRID-singletime-aitoff-e10-e50000_FM3.119','GRID-singletime-aitoff-e10-e50000_FM3.119',NULL,10,NULL,',#@diroutputresults@#,0,all,-1,-1\nFM3.119_ASDC2_I0025,GRID-AITOFF_001,ND\n#@tstart@#\n#@tstop@#\nTT\n#@l@#\n#@b@#\nAIT\n-1\n-1\neb=0 mapsize=360 binsize=0.5 skytype=4 phasecode=6 emin=30 emax=50000 filtercode=0 fovradmax=70 albedorad=75 timestep=1 spectralindex=-2.0\nnop\nnop\n0\nnone\nnop\ndefault\ndefault\n1 -1 1 Binv 2\ndefault\ntbd\ntbd\nD2ACDADB-CFE1-4F5D-8F8D-7341AF73F18B\n#@diroutputrun@#,large,agile-B24-r5\nnop\nGCN_#@ant_sname@#_#@alert_instr_name@#_#@triggerid@#_#@seqnum@#_#@runid@#_#@anst_sname@#_#@tstart@#_#@tstop@#\nComments\ncon\n-----\n-----\n#@contour@#','date\nexport PATH_RES=\"/\"\ncp run.xml MLE0000.conf\n$AGILEPIPE/spot6/analysis.rb MLE0000.conf',0),
	(11,'GRID-singletime-spot6-e10-e50000_FM3.119','GRID-singletime-spot6-e10-e50000_FM3.119',NULL,11,NULL,',#@diroutputresults@#,0,all,-1,-1\nFM3.119_ASDC2_I0025,GRID-AITOFF_001,ND\n#@tstart@#\n#@tstop@#\nTT\n#@l@#\n#@b@#\nARC\n-1\n-1\neb=0 mapsize=180 binsize=0.5 skytype=4 phasecode=6 emin=30 emax=50000 filtercode=0 fovradmax=70 albedorad=75 timestep=1 spectralindex=-2.0\nspotfinder 0 2 10 2 1 50\nnop\n0\ndoublestep=3,3,3\nnop\ndefault\ndefault\ndefault\ndefault\nnone\nnop\nD2ACDADB-CFE1-4F5D-8F8D-7341AF73F18B\n#@diroutputrun@#,large,agile-B24-r5\nnop\nGCN_#@ant_sname@#_#@alert_instr_name@#_#@triggerid@#_#@seqnum@#_#@runid@#_#@anst_sname@#_#@tstart@#_#@tstop@#\nComments\ncon\n-----\n-----\n#@contour@#','date\nexport PATH_RES=\"/\"\ncp run.xml MLE0000.conf\n$AGILEPIPE/spot6/analysis.rb MLE0000.conf',0),
	(12,'MCAL_PLOT','MCAL_PLOT',NULL,12,NULL,'<run id=\"#@runid@#\">\n         <parameter name=\"AlertInfo\" triggerid=\"#@triggerid@#\" seqnum=\"#@seqnum@#\" contname=\"#@contour_name@#\" />\n	<parameter name=\"TimeIntervals\" tmin=\"#@tstart@#\" tmax=\"#@tstop@#\" t0=\"#@tzero@#\" timeunit=\"#@timerefunit@#\" timesys=\"#@timerefname@#\"/>\n        <parameter name=\"Energy\" emin=\"#@emin@#\" emax=\"#@emax@#\" energyBinID=\"\" />\n	<parameter name=\"DirectoryList\" run=\"#@diroutputrun@#\" results=\"#@diroutputresults@#\" runprefix=\"#@runprefix@#\" fitspath=\"/data01/ASDC_PROC2/DATA_2/COR/\" />\n         <parameter name=\"DeleteRun\" value=\"0\" />\n</run>','python $MCALPIPE/MCAL-PLOT.py run.xml',0),
	(13,'GRID UL_FM3.119','GRID_UL_FM3.119',NULL,15,NULL,'GRID_UL\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputresults@#\n#@diroutputrun@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@n_radius@#\n#@n_radius@#\n#@tzero@#\n#@tstart@#\n#@tstop@#\n500\n600\n70\n75\n0\nFM3.119\n----\n#@contour@#\n','date\npython $AGILEPIPE/grid_ul/calculate_grid_ul.py run.xml\n',0),
	(15,'FOV','FOV',NULL,17,NULL,'FOV\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputrun@#\n#@diroutputresults@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@radius@#\n#@tzero@#\n#@tstart@#\n#@tstop@#\n70\n80\n----\n#@contour@#','date\npython $AGILEPIPE/visCheck/create_aitoff_fov_plot.py run.xml\n',0),
	(16,'GRB_FT3ab','GRB_FT3ab',NULL,3,NULL,'GRB\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputresults@#\n#@diroutputrun@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@n_radius@#\n10\n#@tzero@#\n#@tstart@#\n#@tstop@#\n500\n600\n70\n75\n0\nFT3ab\ngrb_pipe\n----\n#@contour@#\n','date\n$AGILEPIPE/grb_gw/grb_gw_new.py run.xml\n',0),
	(17,'GW_FT3ab','GW_FT3ab',NULL,3,NULL,'GW\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputresults@#\n#@diroutputrun@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@n_radius@#\n10\n#@tzero@#\n#@tstart@#\n#@tstop@#\n500\n600\n70\n75\n0\nFT3ab\ngrb_pipe\n----\n#@contour@#\n','date\n$AGILEPIPE/grb_gw/grb_gw_new.py run.xml\n',0),
	(18,'GRID-singletime-aitoff-e10-e50000_FT3','GRID-singletime-aitoff-e10-e50000_FT3ab',NULL,10,NULL,',#@diroutputresults@#,0,all,-1,-1\nFT3ab_ASDC2_I0025,GRID-AITOFF_001,ND\n#@tstart@#\n#@tstop@#\nTT\n#@l@#\n#@b@#\nAIT\n-1\n-1\neb=0 mapsize=360 binsize=0.5 skytype=4 phasecode=6 emin=30 emax=50000 filtercode=0 fovradmax=70 albedorad=75 timestep=1 spectralindex=-2.0\nnop\nnop\n0\nnone\nnop\ndefault\ndefault\n1 -1 1 Binv 2\ndefault\ntbd\ntbd\nD2ACDADB-CFE1-4F5D-8F8D-7341AF73F18B\n#@diroutputrun@#,large,agile-B24-r5\nnop\nGCN_#@ant_sname@#_#@alert_instr_name@#_#@triggerid@#_#@seqnum@#_#@runid@#_#@anst_sname@#_#@tstart@#_#@tstop@#\nComments\ncon\n-----\n-----\n#@contour@#','date\nexport PATH_RES=\"/\"\ncp run.xml MLE0000.conf\n$AGILEPIPE/spot6/analysis.rb MLE0000.conf',0),
	(19,'GRID-singletime-spot6-e10-e50000_FT3','GRID-singletime-spot6-e10-e50000_FT3ab',NULL,11,NULL,',#@diroutputresults@#,0,all,-1,-1\nFT3ab_ASDC2_I0025,GRID-AITOFF_001,ND\n#@tstart@#\n#@tstop@#\nTT\n#@l@#\n#@b@#\nARC\n-1\n-1\neb=0 mapsize=180 binsize=0.5 skytype=4 phasecode=6 emin=30 emax=50000 filtercode=0 fovradmax=70 albedorad=75 timestep=1 spectralindex=-2.0\nspotfinder 0 2 10 2 1 50\nnop\n0\ndoublestep=3,3,3\nnop\ndefault\ndefault\ndefault\ndefault\nnone\nnop\nD2ACDADB-CFE1-4F5D-8F8D-7341AF73F18B\n#@diroutputrun@#,large,agile-B24-r5\nnop\nGCN_#@ant_sname@#_#@alert_instr_name@#_#@triggerid@#_#@seqnum@#_#@runid@#_#@anst_sname@#_#@tstart@#_#@tstop@#\nComments\ncon\n-----\n-----\n#@contour@#','date\nexport PATH_RES=\"/\"\ncp run.xml MLE0000.conf\n$AGILEPIPE/spot6/analysis.rb MLE0000.conf',0),
	(20,'GRID UL_FT3ab','GRID_UL_FT3ab',NULL,15,NULL,'GRID_UL\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputresults@#\n#@diroutputrun@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@n_radius@#\n#@n_radius@#\n#@tzero@#\n#@tstart@#\n#@tstop@#\n500\n600\n70\n75\n0\nFT3ab\n----\n#@contour@#\n','date\npython $AGILEPIPE/grid_ul/calculate_grid_ul.py run.xml\n',0),
	(21,'GRB_FM3.119_lm5','GRB_FM3.119_lm5',NULL,18,NULL,'GRB\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputresults@#\n#@diroutputrun@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@n_radius@#\n10\n#@tzero@#\n#@tstart@#\n#@tstop@#\n500\n600\n70\n75\n0\nFM3.119\nlm5.rb\n----\n#@contour@#\n','date\n$AGILEPIPE/grb_gw/grb_gw_new.py run.xml\n',0),
	(23,'GW_FM3.119_lm5','GW_FM3.119_lm5',NULL,18,NULL,'GW\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputresults@#\n#@diroutputrun@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@n_radius@#\n10\n#@tzero@#\n#@tstart@#\n#@tstop@#\n500\n600\n70\n75\n0\nFM3.119\nlm5.rb\n----\n#@contour@#\n','date\n$AGILEPIPE/grb_gw/grb_gw_new.py run.xml\n',0),
	(25,'GRB_FT3ab_lm5','GRB_FT3ab_lm5',NULL,18,NULL,'GRB\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputresults@#\n#@diroutputrun@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@n_radius@#\n10\n#@tzero@#\n#@tstart@#\n#@tstop@#\n500\n600\n70\n75\n0\nFT3ab\nlm5.rb\n----\n#@contour@#\n','date\n$AGILEPIPE/grb_gw/grb_gw_new.py run.xml\n',0),
	(26,'GW_FT3ab_lm5','GW_FT3ab_lm5',NULL,18,NULL,'GW\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputresults@#\n#@diroutputrun@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@n_radius@#\n10\n#@tzero@#\n#@tstart@#\n#@tstop@#\n500\n600\n70\n75\n0\nFT3ab\nlm5.rb\n----\n#@contour@#\n','date\n$AGILEPIPE/grb_gw/grb_gw_new.py run.xml\n',0),
	(27,'visCheckAux_v2','visCheckAux_v2',NULL,19,NULL,'visCheckAux_v2\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputrun@#\n#@diroutputresults@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@radius@#\n#@tzero@#\n#@tstart@#\n#@tstop@#\n#@ligo_map_url@#\n----\n#@contour@#','date\nsh $AGILEPIPE/visCheck/get_visibility_v2.sh run.xml\n',0),
	(28,'grid_circular','grid_circular',NULL,20,NULL,'GRID_GCN\n#@alert_instr_name@#\n#@triggerid@#\n#@seqnum@#\nfast\n#@runid@#\n#@diroutputresults@#\n#@diroutputrun@#\n#@ant_sname@#\n#@anst_sname@#\n#@l@#\n#@b@#\n#@n_radius@#\n10\n#@tzero@#\n#@tstart@#\n#@tstop@#\n500\n600\n70\n75\n0\nFM3.119\n#@ligo_map_url@#\n----\n#@contour@#\n','date\nsource activate ligo_map_36\npython $AGILEPIPE/grid_circular/calculate_contour_area.py run.xml\nsource deactivate\nsource activate py_alert_pipe_27\npython $AGILEPIPE/grid_circular/create_grid_circular.py run.xml\nsource deactivate ',0);

/*!40000 ALTER TABLE `analysistype` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table catalog
# ------------------------------------------------------------

DROP TABLE IF EXISTS `catalog`;

CREATE TABLE `catalog` (
  `catalogid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `link` varchar(255) DEFAULT NULL,
  `wavelenght` float NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`catalogid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table catalogsource
# ------------------------------------------------------------

DROP TABLE IF EXISTS `catalogsource`;

CREATE TABLE `catalogsource` (
  `idsource` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `l` float NOT NULL,
  `b` float NOT NULL,
  `r` float DEFAULT NULL,
  `catalogid` int(10) unsigned NOT NULL,
  `ella` float DEFAULT NULL,
  `ellb` float DEFAULT NULL,
  `ellphi` float DEFAULT NULL,
  `assoc` varchar(255) DEFAULT NULL,
  `other` varchar(255) DEFAULT NULL,
  `flux` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`idsource`),
  UNIQUE KEY `name` (`name`,`catalogid`),
  KEY `catalogid` (`catalogid`),
  CONSTRAINT `catalogsourceibfk1` FOREIGN KEY (`catalogid`) REFERENCES `catalog` (`catalogid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table cluster
# ------------------------------------------------------------

DROP TABLE IF EXISTS `cluster`;

CREATE TABLE `cluster` (
  `cluster_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `cluster_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cluster_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `cluster` WRITE;
/*!40000 ALTER TABLE `cluster` DISABLE KEYS */;

INSERT INTO `cluster` (`cluster_id`, `cluster_name`)
VALUES
	(3,'agilepipedev');

/*!40000 ALTER TABLE `cluster` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table datalevel
# ------------------------------------------------------------

DROP TABLE IF EXISTS `datalevel`;

CREATE TABLE `datalevel` (
  `datalevelid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(128) DEFAULT NULL,
  PRIMARY KEY (`datalevelid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `datalevel` WRITE;
/*!40000 ALTER TABLE `datalevel` DISABLE KEYS */;

INSERT INTO `datalevel` (`datalevelid`, `name`)
VALUES
	(1,'DL3'),
	(2,NULL);

/*!40000 ALTER TABLE `datalevel` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table dataprocessingtool
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dataprocessingtool`;

CREATE TABLE `dataprocessingtool` (
  `dataprocessingtoolid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(128) NOT NULL,
  `module` text NOT NULL,
  `sciencetool` int(11) NOT NULL,
  `skyreftypeid` int(11) unsigned NOT NULL,
  `timereftypeid` int(11) unsigned NOT NULL,
  PRIMARY KEY (`dataprocessingtoolid`),
  KEY `skyreftypeid` (`skyreftypeid`),
  KEY `timereftype` (`timereftypeid`),
  CONSTRAINT `dataprocessingtool_ibfk_2` FOREIGN KEY (`skyreftypeid`) REFERENCES `skyreftype` (`skyreftypeid`) ON UPDATE CASCADE,
  CONSTRAINT `dataprocessingtool_ibfk_3` FOREIGN KEY (`timereftypeid`) REFERENCES `timereftype` (`timereftypeid`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `dataprocessingtool` WRITE;
/*!40000 ALTER TABLE `dataprocessingtool` DISABLE KEYS */;

INSERT INTO `dataprocessingtool` (`dataprocessingtoolid`, `name`, `module`, `sciencetool`, `skyreftypeid`, `timereftypeid`)
VALUES
	(1,'MCAL','source /opt/module/mcal_pipe_2.0\nsource activate py_mcal_27\n#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ROOTSYS/lib\nsource /opt/module/agile-B25-r5\nsource /opt/module/agile-mcal',1,1,2),
	(2,'MCAL_ALERT','source /opt/module/mcal_pipe_2.0\nsource activate py_mcal_27\n#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ROOTSYS/lib\nsource /opt/module/agile-B25-r5\nsource /opt/module/agile-mcal\nsource /opt/module/heasoft-6.25\n',1,1,2),
	(3,'GRB_py','source /opt/module/alert_pipe_27\nsource activate py_alert_pipe_27\nsource /opt/module/agile-B25-r5',1,1,2),
	(6,'visCheck','source /opt/module/alert_pipe_27\nsource activate py_alert_pipe_27\nsource /opt/module/agile-B25-r5\nsource /opt/module/idl8.2sp2',1,1,2),
	(7,'ratemeters','source /opt/module/alert_pipe_27\nsource activate py_alert_pipe_27\nsource /opt/module/heasoft-6.25\nexport HEADASNOQUERY=0',1,1,2),
	(9,'ATstatus','source /opt/module/alert_pipe_27\nsource activate py_alert_pipe_27\nsource /opt/module/agile-B25-r5',1,1,2),
	(10,'spot6','source activate py_alert_pipe_27\nsource /opt/module/agile-B25-r5',1,1,2),
	(11,'spot6','source activate py_alert_pipe_27\nsource /opt/module/agile-B25-r5',1,1,2),
	(12,'MCAL_PLOT','source /opt/module/mcal_pipe_2.0\nsource activate py_mcal_27\nsource /opt/module/agile-B25-r5\nsource /opt/module/agile-mcal',1,1,2),
	(15,'GRID_UL','source /opt/module/alert_pipe_27\nsource activate py_alert_pipe_27\nsource /opt/module/agile-B25-r5',1,1,2),
	(17,'FOV','source /opt/module/alert_pipe_27\nsource activate py_alert_pipe_27\nsource /opt/module/heasoft-6.25\nexport HEADASNOQUERY=0\nPATH=$AGILEPIPE/visCheck:$PATH',1,1,2),
	(18,'GRB_py_lm5','source /opt/module/alert_pipe_27\nsource activate py_alert_pipe_27\nsource /opt/module/agile-B25-r5',1,1,2),
	(19,'visCheck_v2','source /opt/module/alert_pipe_27\nsource activate ligo_map_36\nsource /opt/module/agile-B25-r5\nsource /opt/module/idl8.2sp2',1,1,2),
	(20,'grid_circular','source /opt/module/alert_pipe_27\nsource /opt/module/agile-B25-r5',1,1,2);

/*!40000 ALTER TABLE `dataprocessingtool` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table dataprocessingtool_datatype_input
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dataprocessingtool_datatype_input`;

CREATE TABLE `dataprocessingtool_datatype_input` (
  `dataprocessingtoolid` int(10) unsigned NOT NULL,
  `datatypeid` int(10) unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT '1',
  `required` int(11) NOT NULL,
  PRIMARY KEY (`datatypeid`,`dataprocessingtoolid`),
  KEY `sciencetoolid` (`dataprocessingtoolid`),
  CONSTRAINT `dataprocessingtool_datatype_input_ibfk_1` FOREIGN KEY (`dataprocessingtoolid`) REFERENCES `dataprocessingtool` (`dataprocessingtoolid`),
  CONSTRAINT `dataprocessingtool_datatype_input_ibfk_2` FOREIGN KEY (`datatypeid`) REFERENCES `datatype` (`datatypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `dataprocessingtool_datatype_input` WRITE;
/*!40000 ALTER TABLE `dataprocessingtool_datatype_input` DISABLE KEYS */;

INSERT INTO `dataprocessingtool_datatype_input` (`dataprocessingtoolid`, `datatypeid`, `type`, `required`)
VALUES
	(1,1,1,1),
	(2,1,0,0),
	(12,1,0,0),
	(1,4,0,1),
	(2,4,1,1),
	(12,4,1,1),
	(3,5,1,1),
	(10,5,1,1),
	(11,5,1,1),
	(15,5,1,1),
	(18,5,1,1),
	(20,5,1,1),
	(2,6,0,1),
	(3,6,0,1),
	(9,6,1,1),
	(10,6,0,1),
	(11,6,0,1),
	(15,6,0,1),
	(17,6,1,1),
	(18,6,0,1),
	(20,6,0,1),
	(6,7,1,1),
	(19,7,1,1),
	(6,9,0,1),
	(19,9,0,1),
	(7,10,1,1),
	(2,12,0,1),
	(7,12,0,1);

/*!40000 ALTER TABLE `dataprocessingtool_datatype_input` ENABLE KEYS */;
UNLOCK TABLES;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`188.15.168.50` */ /*!50003 TRIGGER `dataprocessingtool_datatype_insert` AFTER INSERT ON `dataprocessingtool_datatype_input` FOR EACH ROW trigger_label: BEGIN


		

		DECLARE number_of_datatype_master INT UNSIGNED;

		SELECT COUNT(*) INTO number_of_datatype_master from dataprocessingtool_datatype_input where dataprocessingtoolid = NEW.dataprocessingtoolid and type = 1;

		IF number_of_datatype_master > 1 THEN

			SIGNAL SQLSTATE '45000'  SET MESSAGE_TEXT = "You can not have more than one master datatype for dataprocessingtool";

        END IF;

END */;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`188.15.168.50` */ /*!50003 TRIGGER `dataprocessingtool_datatype_update` AFTER UPDATE ON `dataprocessingtool_datatype_input` FOR EACH ROW trigger_label: BEGIN


		

		DECLARE number_of_datatype_master INT UNSIGNED;

		SELECT COUNT(*) INTO number_of_datatype_master from dataprocessingtool_datatype_input where dataprocessingtoolid = NEW.dataprocessingtoolid and type = 1;

		IF number_of_datatype_master > 1 THEN

			SIGNAL SQLSTATE '45000'  SET MESSAGE_TEXT = "You can not have more than one master datatype for dataprocessingtool";

        END IF;

END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# Dump of table dataprocessingtool_datatype_output
# ------------------------------------------------------------

DROP TABLE IF EXISTS `dataprocessingtool_datatype_output`;

CREATE TABLE `dataprocessingtool_datatype_output` (
  `dataprocessingtoolid` int(11) unsigned NOT NULL,
  `datatypeid` int(11) unsigned NOT NULL,
  PRIMARY KEY (`dataprocessingtoolid`,`datatypeid`),
  KEY `datatypeid` (`datatypeid`),
  CONSTRAINT `dataprocessingtool_datatype_output_ibfk_1` FOREIGN KEY (`dataprocessingtoolid`) REFERENCES `dataprocessingtool` (`dataprocessingtoolid`),
  CONSTRAINT `dataprocessingtool_datatype_output_ibfk_2` FOREIGN KEY (`datatypeid`) REFERENCES `datatype` (`datatypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table datarepository
# ------------------------------------------------------------

DROP TABLE IF EXISTS `datarepository`;

CREATE TABLE `datarepository` (
  `datarepositoryid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `datatypeid` int(10) unsigned NOT NULL,
  `category` int(11) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `active` int(11) NOT NULL,
  PRIMARY KEY (`datarepositoryid`),
  KEY `datatypeid` (`datatypeid`),
  CONSTRAINT `datarepositoryibfk1` FOREIGN KEY (`datatypeid`) REFERENCES `datatype` (`datatypeid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `datarepository` WRITE;
/*!40000 ALTER TABLE `datarepository` DISABLE KEYS */;

INSERT INTO `datarepository` (`datarepositoryid`, `datatypeid`, `category`, `name`, `description`, `active`)
VALUES
	(1,1,0,'','3908',1),
	(2,4,0,'','3916',1),
	(3,5,0,'','EVT files',1),
	(4,6,0,'','LOG files',1),
	(5,7,0,'','EARTH files',1),
	(6,9,0,'','SAS files',1),
	(7,10,0,'','COR_3201',1),
	(8,12,0,'','COR_3913',1);

/*!40000 ALTER TABLE `datarepository` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table datatype
# ------------------------------------------------------------

DROP TABLE IF EXISTS `datatype`;

CREATE TABLE `datatype` (
  `datatypeid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(128) DEFAULT NULL,
  `datalevelid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`datatypeid`),
  KEY `datalevelid` (`datalevelid`),
  CONSTRAINT `datatype_ibfk_2` FOREIGN KEY (`datalevelid`) REFERENCES `datalevel` (`datalevelid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `datatype` WRITE;
/*!40000 ALTER TABLE `datatype` DISABLE KEYS */;

INSERT INTO `datatype` (`datatypeid`, `name`, `datalevelid`)
VALUES
	(1,'COR_3908',1),
	(4,'COR_3916',1),
	(5,'EVT',1),
	(6,'LOG',1),
	(7,'EARTH',1),
	(9,'SAS',1),
	(10,'COR_3201',1),
	(12,'COR_3913',1);

/*!40000 ALTER TABLE `datatype` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table energybin
# ------------------------------------------------------------

DROP TABLE IF EXISTS `energybin`;

CREATE TABLE `energybin` (
  `energybinid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `energybingroupid` int(10) unsigned NOT NULL,
  `emin` double DEFAULT NULL,
  `emax` double DEFAULT NULL,
  PRIMARY KEY (`energybinid`),
  KEY `energybingroupid` (`energybingroupid`),
  CONSTRAINT `energybinibfk1` FOREIGN KEY (`energybingroupid`) REFERENCES `energybingroup` (`energybingroupid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `energybin` WRITE;
/*!40000 ALTER TABLE `energybin` DISABLE KEYS */;

INSERT INTO `energybin` (`energybinid`, `energybingroupid`, `emin`, `emax`)
VALUES
	(6,1,0.1,100);

/*!40000 ALTER TABLE `energybin` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table energybingroup
# ------------------------------------------------------------

DROP TABLE IF EXISTS `energybingroup`;

CREATE TABLE `energybingroup` (
  `energybingroupid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `shortname` char(15) NOT NULL,
  `description` text,
  `energyreftypeid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`energybingroupid`),
  UNIQUE KEY `shortname` (`shortname`),
  KEY `energyreftypeid` (`energyreftypeid`),
  CONSTRAINT `energybingroupibfk1` FOREIGN KEY (`energyreftypeid`) REFERENCES `energyreftype` (`energyreftypeid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `energybingroup` WRITE;
/*!40000 ALTER TABLE `energybingroup` DISABLE KEYS */;

INSERT INTO `energybingroup` (`energybingroupid`, `shortname`, `description`, `energyreftypeid`)
VALUES
	(1,'fullband','Full Band',1);

/*!40000 ALTER TABLE `energybingroup` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table energyreftype
# ------------------------------------------------------------

DROP TABLE IF EXISTS `energyreftype`;

CREATE TABLE `energyreftype` (
  `energyreftypeid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(128) DEFAULT NULL,
  PRIMARY KEY (`energyreftypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `energyreftype` WRITE;
/*!40000 ALTER TABLE `energyreftype` DISABLE KEYS */;

INSERT INTO `energyreftype` (`energyreftypeid`, `name`)
VALUES
	(1,'MeV'),
	(2,'TeV'),
	(5,'Not Specified');

/*!40000 ALTER TABLE `energyreftype` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table instrument
# ------------------------------------------------------------

DROP TABLE IF EXISTS `instrument`;

CREATE TABLE `instrument` (
  `instrumentid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL DEFAULT '',
  `obsinstrparentid` int(10) unsigned DEFAULT NULL,
  `description` text,
  `array` varchar(5) DEFAULT NULL,
  `subarray` varchar(128) DEFAULT NULL,
  `observatoryinstrument` tinyint(1) DEFAULT NULL,
  `basenoticeurl` varchar(255) DEFAULT NULL,
  `irf` varchar(255) DEFAULT NULL,
  `caldb` varchar(255) DEFAULT NULL,
  `fov` double DEFAULT NULL,
  `fixedid` int(11) DEFAULT NULL,
  PRIMARY KEY (`instrumentid`),
  UNIQUE KEY `fixedid` (`fixedid`),
  KEY `obsinstrparentid` (`obsinstrparentid`),
  CONSTRAINT `instrument_ibfk_1` FOREIGN KEY (`obsinstrparentid`) REFERENCES `instrument` (`instrumentid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `instrument` WRITE;
/*!40000 ALTER TABLE `instrument` DISABLE KEYS */;

INSERT INTO `instrument` (`instrumentid`, `name`, `obsinstrparentid`, `description`, `array`, `subarray`, `observatoryinstrument`, `basenoticeurl`, `irf`, `caldb`, `fov`, `fixedid`)
VALUES
	(1,'FERMI_GBM',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	(2,'FERMI_LAT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	(3,'SWIFT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	(4,'AGILE_GRID',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,180,NULL),
	(5,'AGILE_MCAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,180,NULL),
	(6,'AGILE_SA',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,180,NULL),
	(7,'LIGO',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	(8,'ICECUBE_HESE',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	(9,'AGILE',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,180,NULL),
	(10,'ICECUBE_EHE',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,180,NULL),
	(17,'AGILE_MCAL_AU',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,180,NULL),
	(19,'LIGO_TEST',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	(20,'FRB',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	(21,'ICECUBE_ASTROTRACK_GOLD',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	(22,'ICECUBE_ASTROTRACK_BRONZE',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	(23,'INTEGRAL',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL);

/*!40000 ALTER TABLE `instrument` ENABLE KEYS */;
INSERT INTO `instrument` (`name`, `obsinstrparentid`, `description`, `array`, `subarray`, `observatoryinstrument`, `basenoticeurl`, `irf`, `caldb`, `fov`, `fixedid`) VALUES 
	('TEST',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
UPDATE `instrument` SET `instrumentid` = '0' WHERE (`name` = 'TEST');
UNLOCK TABLES;


# Dump of table instrumentgti
# ------------------------------------------------------------

DROP TABLE IF EXISTS `instrumentgti`;

CREATE TABLE `instrumentgti` (
  `instrumentgtiid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `instrumentid` int(10) unsigned NOT NULL,
  `tstart` double DEFAULT NULL,
  `tstop` double DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  PRIMARY KEY (`instrumentgtiid`),
  KEY `instrumentid` (`instrumentid`),
  CONSTRAINT `instrumentgtiibfk1` FOREIGN KEY (`instrumentid`) REFERENCES `instrument` (`instrumentid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table log
# ------------------------------------------------------------

DROP TABLE IF EXISTS `log`;

CREATE TABLE `log` (
  `t` datetime DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table network
# ------------------------------------------------------------

DROP TABLE IF EXISTS `network`;

CREATE TABLE `network` (
  `networkid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(128) NOT NULL,
  `external` int(1) NOT NULL,
  `fixedid` int(11) DEFAULT NULL,
  PRIMARY KEY (`networkid`),
  UNIQUE KEY `fixedid` (`fixedid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `network` WRITE;
/*!40000 ALTER TABLE `network` DISABLE KEYS */;

INSERT INTO `network` (`networkid`, `name`, `external`, `fixedid`)
VALUES
	(1,'GCN',1,NULL),
	(2,'AGILEPIPE',0,NULL),
	(3,'MANUAL',0,NULL),
	(4,'CHIME',1,NULL),
	(6,'INTEGRAL',1,NULL);

/*!40000 ALTER TABLE `network` ENABLE KEYS */;
INSERT INTO `network` (`name`, `external`, `fixedid`) VALUES ('TEST',0,NULL);
UPDATE `network` SET `networkid` = '0' WHERE (`name` = 'TEST');
UNLOCK TABLES;


# Dump of table notice
# ------------------------------------------------------------

DROP TABLE IF EXISTS `notice`;

CREATE TABLE `notice` (
  `noticeid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `receivedsciencealertid` int(10) unsigned NOT NULL,
  `seqnum` int(11) NOT NULL,
  `l` double NOT NULL,
  `b` double NOT NULL,
  `error` double NOT NULL,
  `contour` mediumtext NOT NULL,
  `last` int(1) NOT NULL,
  `type` int(11) DEFAULT NULL,
  `configuration` varchar(50) DEFAULT NULL,
  `noticetime` char(20) DEFAULT NULL,
  `notice` text,
  `tstart` double DEFAULT NULL,
  `tstop` double DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `attributes` json DEFAULT NULL,
  `checked` int(11) NOT NULL DEFAULT '0',
  `afisscheck` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`noticeid`),
  UNIQUE KEY `receivedsciencealertid` (`receivedsciencealertid`,`seqnum`),
  CONSTRAINT `noticeibfk1` FOREIGN KEY (`receivedsciencealertid`) REFERENCES `receivedsciencealert` (`receivedsciencealertid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`188.15.168.50` */ /*!50003 TRIGGER `notice_insert` AFTER INSERT ON `notice` FOR EACH ROW trigger_label: BEGIN


		

        BEGIN
			DECLARE analysissessiontype_id INT UNSIGNED;
			DECLARE delta_tstart  DOUBLE;
			DECLARE delta_tstop  DOUBLE;
			DECLARE tzero  DOUBLE;
			DECLARE done INT DEFAULT FALSE;
			DECLARE cur1 CURSOR FOR SELECT ast.analysissessiontypeid,ast.deltatstart,ast.deltatstop,rsa.time FROM analysissessiontype ast JOIN analysistrigger ant ON (ast.analysistriggerid = ant.analysistriggerid) JOIN receivedsciencealert rsa ON (rsa.instrumentid = ant.triggersourcesciencealertinstrumentid) JOIN notice n ON(n.receivedsciencealertid = rsa.receivedsciencealertid)
			WHERE  ant.status = 1 AND  n.noticeid = NEW.noticeid and ast.runnable = 1;
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

			OPEN cur1;


			read_loop: LOOP

				FETCH cur1 INTO analysissessiontype_id,delta_tstart,delta_tstop,tzero;

				IF done THEN
					LEAVE read_loop;
				END IF;

				
				INSERT INTO analysissessiontype_notice (analysissessiontypeid,noticeid,tstart,tstop) VALUES (analysissessiontype_id,NEW.noticeid,tzero+delta_tstart,tzero+delta_tstop);

				INSERT INTO log SELECT now(), concat('new  analysissessiontype_notice ', analysissessiontype_id,' for notice ',NEW.noticeid);


			END LOOP;

			CLOSE cur1;
        END;




END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# Dump of table observation
# ------------------------------------------------------------

DROP TABLE IF EXISTS `observation`;

CREATE TABLE `observation` (
  `observationid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `tstartplanned` double DEFAULT NULL,
  `tendplanned` double DEFAULT NULL,
  `tstartreal` double DEFAULT NULL,
  `tendreal` double DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `fitspath` varchar(255) DEFAULT NULL,
  `l` double NOT NULL,
  `b` double NOT NULL,
  `timereftypeid` int(10) unsigned NOT NULL,
  `skyreftypeid` int(11) unsigned NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`observationid`),
  KEY `timereftypeid` (`timereftypeid`),
  KEY `skyreftypeid` (`skyreftypeid`),
  CONSTRAINT `observation_ibfk_1` FOREIGN KEY (`timereftypeid`) REFERENCES `timereftype` (`timereftypeid`),
  CONSTRAINT `observation_ibfk_2` FOREIGN KEY (`skyreftypeid`) REFERENCES `skyreftype` (`skyreftypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `observation` WRITE;
/*!40000 ALTER TABLE `observation` DISABLE KEYS */;

INSERT INTO `observation` (`observationid`, `tstartplanned`, `tendplanned`, `tstartreal`, `tendreal`, `status`, `fitspath`, `l`, `b`, `timereftypeid`, `skyreftypeid`, `name`)
VALUES
	(1,0,1000000000000,0,NULL,1,NULL,0,0,1,2,'AGILEobs');

/*!40000 ALTER TABLE `observation` ENABLE KEYS */;
UNLOCK TABLES;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`188.15.168.50` */ /*!50003 TRIGGER `observation_update` AFTER UPDATE ON `observation` FOR EACH ROW trigger_label: BEGIN

        

		IF    (OLD.tstartreal IS NULL AND NEW.tstartreal is not null AND NEW.status = 1 ) THEN 

				
				INSERT INTO log SELECT now(), concat('update tstartreal');
                BEGIN

					DECLARE done INT DEFAULT FALSE;
                    DECLARE datarepository_id INT UNSIGNED;

					DECLARE cur1 CURSOR FOR SELECT datarepositoryid from datarepository dr JOIN observatoryinstrument_produce_datatype oidt ON (oidt.datatypeid= dr.datatypeid) JOIN observingmode obm
                    ON (obm.instrumentid = oidt.instrumentid) JOIN  target t ON (t.observingmodeid = obm.observingmodeid) JOIN observation_target ot ON (t.targetid = ot.targetid)
                    WHERE dr.active = 1 AND ot.observationid = NEW.observationid;

					DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

					OPEN cur1;

					read_loop: LOOP

						FETCH cur1 INTO datarepository_id;

						IF done THEN
							LEAVE read_loop;
						END IF;

						INSERT INTO observation_to_datarepository (datarepositoryid,observationid,tstartdata) VALUES (datarepository_id,NEW.observationid,NEW.tstartreal);

					END LOOP;

					CLOSE cur1;
                END;

        END IF;

        
        IF  (OLD.tendreal IS NULL AND NEW.tendreal is not null  AND NEW.status = 1) THEN 


				

                INSERT INTO log SELECT now(), concat('update tendreal');


                BEGIN

					DECLARE done INT DEFAULT FALSE;
                    DECLARE analysissessiontype_notice_observation_id INT UNSIGNED;

					DECLARE cur1 CURSOR FOR SELECT analysissessiontype_notice_observationid FROM analysissessiontype_notice_observation WHERE observationid = NEW.observationid AND active = 1;

					DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

					OPEN cur1;

					read_loop: LOOP

						FETCH cur1 INTO analysissessiontype_notice_observation_id;

						IF done THEN
							LEAVE read_loop;
						END IF;

						INSERT INTO log SELECT now(), concat('deactivate analysissessiontype_notice_observation ', analysissessiontype_notice_observation_id);

                        UPDATE analysissessiontype_notice_observation SET active = 0 WHERE analysissessiontype_notice_observationid = analysissessiontype_notice_observation_id;

                        
                        UPDATE run SET STATUS = 8 WHERE status IN (1,2,3,4) AND  tstop >= NEW.tendreal AND analysissessionid IN (SELECT analysissessionid FROM analysissession  ans WHERE ans.analysissessiontype_notice_observationid = analysissessiontype_notice_observation_id ) ;

					END LOOP;

					CLOSE cur1;
                END;

        END IF;

END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# Dump of table observation_of_receivedsciencealert
# ------------------------------------------------------------

DROP TABLE IF EXISTS `observation_of_receivedsciencealert`;

CREATE TABLE `observation_of_receivedsciencealert` (
  `observationid` int(10) unsigned NOT NULL,
  `receivedsciencealertid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`receivedsciencealertid`,`observationid`),
  KEY `observationofreceivedsciencealertibfk1` (`observationid`),
  CONSTRAINT `observationofreceivedsciencealertibfk1` FOREIGN KEY (`observationid`) REFERENCES `observation` (`observationid`) ON DELETE CASCADE,
  CONSTRAINT `observationofreceivedsciencealertibfk2` FOREIGN KEY (`receivedsciencealertid`) REFERENCES `receivedsciencealert` (`receivedsciencealertid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table observation_parameters
# ------------------------------------------------------------

DROP VIEW IF EXISTS `observation_parameters`;

CREATE TABLE `observation_parameters` (
   `observationid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `tstartplanned` DOUBLE NULL DEFAULT NULL,
   `tendplanned` DOUBLE NULL DEFAULT NULL,
   `tstartreal` DOUBLE NULL DEFAULT NULL,
   `tendreal` DOUBLE NULL DEFAULT NULL,
   `status` INT(11) NULL DEFAULT NULL,
   `fitspath` VARCHAR(255) NULL DEFAULT NULL,
   `l` DOUBLE NOT NULL,
   `b` DOUBLE NOT NULL,
   `timereftypeid` INT(10) UNSIGNED NOT NULL,
   `skyreftypeid` INT(11) UNSIGNED NOT NULL,
   `name` VARCHAR(255) NULL DEFAULT NULL,
   `observingmodeid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `instrumentid` INT(10) UNSIGNED NOT NULL,
   `zenithangle` DOUBLE NULL DEFAULT NULL,
   `minskyquality` INT(11) NULL DEFAULT NULL,
   `minnsb` INT(11) NULL DEFAULT NULL,
   `maxnsb` INT(11) NULL DEFAULT NULL,
   `instrumentname` VARCHAR(128) NOT NULL DEFAULT '',
   `irf` VARCHAR(255) NULL DEFAULT NULL,
   `caldb` VARCHAR(255) NULL DEFAULT NULL,
   `fov` DOUBLE NULL DEFAULT NULL,
   `emin` DOUBLE NULL DEFAULT NULL,
   `emax` DOUBLE NULL DEFAULT NULL,
   `targetid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `targetxmlmodel` TEXT NULL DEFAULT NULL,
   `skyrefname` CHAR(10) NOT NULL DEFAULT '',
   `timerefunit` VARCHAR(10) NOT NULL DEFAULT '',
   `skyrefunit` VARCHAR(10) NOT NULL DEFAULT '',
   `timerefname` CHAR(128) NOT NULL DEFAULT ''
) ENGINE=MyISAM;



# Dump of table observation_target
# ------------------------------------------------------------

DROP TABLE IF EXISTS `observation_target`;

CREATE TABLE `observation_target` (
  `observationid` int(10) unsigned NOT NULL,
  `targetid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`targetid`,`observationid`),
  KEY `observationid` (`observationid`),
  KEY `targetid` (`targetid`),
  CONSTRAINT `observation_target_ibfk_1` FOREIGN KEY (`targetid`) REFERENCES `target` (`targetid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `observation_target_ibfk_2` FOREIGN KEY (`observationid`) REFERENCES `observation` (`observationid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `observation_target` WRITE;
/*!40000 ALTER TABLE `observation_target` DISABLE KEYS */;

INSERT INTO `observation_target` (`observationid`, `targetid`)
VALUES
	(1,1);

/*!40000 ALTER TABLE `observation_target` ENABLE KEYS */;
UNLOCK TABLES;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`188.15.168.50` */ /*!50003 TRIGGER `observation_target_check_instrument_before_insert` BEFORE INSERT ON `observation_target` FOR EACH ROW trigger_label: BEGIN


        DECLARE obs_instrument_id INT UNSIGNED;
        DECLARE this_instrument_id INT UNSIGNED;

		SELECT instrumentid INTO obs_instrument_id from observation_target ot JOIN target t ON(t.targetid = ot.targetid) JOIN observingmode om ON(om.observingmodeid = t.observingmodeid)  where observationid = NEW.observationid ;
		SELECT instrumentid INTO this_instrument_id from target t JOIN observingmode om ON(om.observingmodeid = t.observingmodeid)  where targetid = NEW.targetid ;

		INSERT INTO log SELECT now(), concat('check observation_target, instrumentid =  ', obs_instrument_id,' ',obs_instrument_id);

        IF obs_instrument_id !=  this_instrument_id THEN
				SIGNAL SQLSTATE '45000'  SET MESSAGE_TEXT = "Can't add to the same observation two target with different instrumentid";
        END IF;


END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# Dump of table observation_to_datarepository
# ------------------------------------------------------------

DROP TABLE IF EXISTS `observation_to_datarepository`;

CREATE TABLE `observation_to_datarepository` (
  `datarepositoryid` int(10) unsigned NOT NULL,
  `observationid` int(10) unsigned NOT NULL,
  `tstartdata` double DEFAULT NULL,
  `tenddata` double DEFAULT NULL,
  PRIMARY KEY (`observationid`,`datarepositoryid`),
  KEY `observationtodatarepositoryibfk2` (`datarepositoryid`),
  CONSTRAINT `observationtodatarepositoryibfk1` FOREIGN KEY (`observationid`) REFERENCES `observation` (`observationid`) ON DELETE CASCADE,
  CONSTRAINT `observationtodatarepositoryibfk2` FOREIGN KEY (`datarepositoryid`) REFERENCES `datarepository` (`datarepositoryid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `observation_to_datarepository` WRITE;
/*!40000 ALTER TABLE `observation_to_datarepository` DISABLE KEYS */;

INSERT INTO `observation_to_datarepository` (`datarepositoryid`, `observationid`, `tstartdata`, `tenddata`)
VALUES
	(1,1,0,534157047.026987),
	(2,1,0,534159290),
	(3,1,0,514082644),
	(4,1,0,534159289.9),
	(5,1,0,10000000000),
	(6,1,0,10000000000),
	(7,1,0,534159289.264592),
	(8,1,0,534159303.658608);

/*!40000 ALTER TABLE `observation_to_datarepository` ENABLE KEYS */;
UNLOCK TABLES;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`188.15.168.50` */ /*!50003 TRIGGER `observation_to_datarepository_insert` AFTER INSERT ON `observation_to_datarepository` FOR EACH ROW trigger_label: BEGIN


        

        DECLARE done INT DEFAULT FALSE;
		DECLARE analysissessiontype_notice_id  INT UNSIGNED;

		DECLARE cur1 CURSOR FOR SELECT analysissessiontype_noticeid FROM analysissessiontype_notice anstn JOIN notice n ON (n.noticeid = anstn.noticeid) JOIN analysissessiontype anst ON (anst.analysissessiontypeid = anstn.analysissessiontypeid)
        JOIN analysistype ant ON (ant.analysistypeid = anst.analysistypeid) JOIN dataprocessingtool dpt ON (dpt.dataprocessingtoolid = ant.dataprocessingtoolid)
        JOIN dataprocessingtool_datatype_input dptdti ON (dptdti.dataprocessingtoolid=dpt.dataprocessingtoolid) WHERE n.last = 1 AND  dptdti.type = 1
        AND dptdti.datatypeid = (SELECT datatypeid FROM datarepository dr WHERE dr.datarepositoryid = NEW.datarepositoryid)
        AND NEW.tstartdata <= anstn.tstop AND NEW.tenddata >= anstn.tstart;

		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		OPEN cur1;

		read_loop: LOOP

			FETCH cur1 INTO analysissessiontype_notice_id;

			IF done THEN
				LEAVE read_loop;
			END IF;

            INSERT INTO analysissessiontype_notice_observation (analysissessiontype_noticeid,observationid,active) VALUES (analysissessiontype_notice_id,NEW.observationid,1);

		END LOOP;

		CLOSE cur1;


END */;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`188.15.168.50` */ /*!50003 TRIGGER `datarepository_update_create_run` AFTER UPDATE ON `observation_to_datarepository` FOR EACH ROW trigger_label: BEGIN

        DECLARE analysistrigger_id INT UNSIGNED;
        DECLARE analysissessiontype_id INT UNSIGNED;
        DECLARE analysisitype_id INT UNSIGNED;
        DECLARE aggregation_id INT;
        DECLARE timestep_seconds DOUBLE;
        DECLARE timebinsize_seconds DOUBLE;
        DECLARE al_repository_updated INT DEFAULT TRUE;
        DECLARE done INT DEFAULT FALSE;
        DECLARE max_tstart_all DOUBLE;
        DECLARE min_tstop_all DOUBLE;
        DECLARE tstoplast_run DOUBLE;
        DECLARE tstartlast_run DOUBLE;
        DECLARE time_start_run DOUBLE;
        DECLARE time_stop_run DOUBLE;
        DECLARE good_time_window BOOLEAN;
        DECLARE analysissessiontype_observation_id INT UNSIGNED;
        DECLARE analysissession_id INT UNSIGNED;
        DECLARE skyposition_type INT;
        DECLARE energybingroup_id INT UNSIGNED;
        DECLARE skyringgroup_id INT UNSIGNED;
        DECLARE basedir_results TEXT;
        DECLARE basedir_run TEXT;
        DECLARE instrument_name VARCHAR(128);
        DECLARE datarepository_name VARCHAR(255);
        DECLARE analysissessiontype_shortname VARCHAR(255);
        DECLARE analysistype_shortname VARCHAR(255);
        DECLARE analysis_session_dir VARCHAR(255);
		DECLARE run_dir VARCHAR(255);
        DECLARE analysis_radius DOUBLE;
        DECLARE analysissessiontype_observationid_count INT;


		DECLARE cur1 CURSOR FOR SELECT analysissessiontypeid,analysistypeid,aggregation,timestep,timebinsize,skypositiontype,energybingroupid,skyringgroupid,shortname,analysisradius FROM analysissessiontype WHERE analysistriggerid = analysistrigger_id and runnable = 1;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

		
		IF NEW.tenddata = OLD.tenddata OR NEW.tenddata < OLD.tenddata  OR NEW.tenddata <= NEW.tstartdata THEN
			LEAVE trigger_label;
		END IF;

		
		SELECT analysistriggerid,basedirresults,basedirrun,instrument.name INTO analysistrigger_id,basedir_results,basedir_run,instrument_name FROM analysistrigger join instrument on(analysistrigger.triggersourcedatarepositoryidinstrumentid = instrument.instrumentid) WHERE  analysistrigger.status = 1 AND  triggersourcedatarepositoryid = NEW.datarepositoryid AND triggersourcedatarepositoryidinstrumentid = ( select instrumentid from observation_parameters where observationid = NEW.observationid );

		
		SELECT name INTO datarepository_name FROM datarepository WHERE datarepositoryid = NEW.datarepositoryid;

	
		

		OPEN cur1;
        
		read_loop: LOOP

			FETCH cur1 INTO analysissessiontype_id,analysisitype_id,aggregation_id,timestep_seconds,timebinsize_seconds,skyposition_type,energybingroup_id,skyringgroup_id,analysissessiontype_shortname,analysis_radius;

			INSERT INTO log SELECT now(), concat('analysissessiontype  ', analysissessiontype_id);

            IF done THEN
				LEAVE read_loop;
			END IF;

			
			
			BEGIN


				DECLARE done2 INT DEFAULT FALSE;
				DECLARE datarepository_id INT UNSIGNED;

				DECLARE tstart_st_repository DOUBLE;
				DECLARE tstop_st_repository DOUBLE;


                DECLARE analysissessiontype_observation_tstop DOUBLE;

				DECLARE cur2 CURSOR FOR SELECT dr.datarepositoryid from datarepository dr join dataprocessingtool_datatype_input dpt  on (dr.datatypeid = dpt.datatypeid ) join analysistype ant on(dpt.dataprocessingtoolid = ant.dataprocessingtoolid) join analysissessiontype ast on(ast.analysistypeid = ant.analysistypeid )
				WHERE analysissessiontypeid = analysissessiontype_id and dr.active=1 and dpt.required = 1;
				DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;

                SET max_tstart_all = 0;
                SET min_tstop_all = 100000000000;

				OPEN cur2;
				
				read_loop2: LOOP

					FETCH cur2 INTO datarepository_id;

					IF done2 THEN
						LEAVE read_loop2;
					END IF;

					SELECT otd.tstartdata,otd.tenddata INTO tstart_st_repository,tstop_st_repository   FROM observation_to_datarepository otd WHERE otd.observationid = NEW.observationid AND datarepositoryid = datarepository_id;

					IF tstart_st_repository > max_tstart_all THEN

                        SET max_tstart_all = tstart_st_repository;

                    END IF;

                    IF tstop_st_repository < min_tstop_all THEN

                        SET min_tstop_all = tstop_st_repository;

                    END IF;



				END LOOP;

				CLOSE cur2;
            END;

      


			
			SELECT count(*),analysissessiontype_observationid,tstartlastrun,tstoplastrun INTO analysissessiontype_observationid_count,analysissessiontype_observation_id,tstartlast_run,tstoplast_run FROM analysissessiontype_observation WHERE observationid = NEW.observationid AND analysissessiontypeid = analysissessiontype_id;
			INSERT INTO log SELECT now(), concat('count',analysissessiontype_observationid_count,'tstartlast_run=', tstartlast_run,' tstoplast_run= ',tstoplast_run);

			IF analysissessiontype_observationid_count = 0 THEN

					
                    INSERT INTO analysissessiontype_observation (analysissessiontypeid,observationid,tstartlastrun,tstoplastrun) VALUES (analysissessiontype_id,NEW.observationid,NEW.tstartdata-timestep_seconds,NULL);
					SET tstartlast_run = NEW.tstartdata-timestep_seconds;
					SET tstoplast_run = NEW.tstartdata;
                    SET  analysissessiontype_observation_id = LAST_INSERT_ID();

                    INSERT INTO log SELECT now(), concat('new analysissessiontype_observation tstartlastrun= ',tstartlast_run);

            END IF;


            


            IF timebinsize_seconds = -1 THEN

                SET time_start_run = tstoplast_run;
				SET time_stop_run = NEW.tenddata;

             ELSEIF timebinsize_seconds = -2 THEN

                SET time_start_run = NEW.tstartdata;
				SET time_stop_run = tstoplast_run + timestep_seconds;

			ELSE
				SET time_start_run = tstartlast_run + timestep_seconds;
				SET time_stop_run = time_start_run + timebinsize_seconds;
            END IF;

            
            SELECT ant.shortname into analysistype_shortname FROM analysistype ant join analysissessiontype anst on (anst.analysistypeid = ant.analysistypeid) WHERE  analysissessiontypeid = analysissessiontype_id;


            
            create_run: WHILE  time_stop_run <= NEW.tenddata DO


				UPDATE analysissessiontype_observation SET tstartlastrun = time_start_run,tstoplastrun = time_stop_run  WHERE observationid = NEW.observationid AND analysissessiontypeid = analysissessiontype_id;

				

                

                SET good_time_window = TRUE;

                BEGIN


					DECLARE done3 INT DEFAULT FALSE;

                    DECLARE tstart_tw DOUBLE;
                    DECLARE tstop_tw DOUBLE;

					DECLARE cur3 CURSOR FOR SELECT tstart,tstop FROM observationwindowstatus WHERE observationid = NEW.observationid AND status = 0;
					DECLARE CONTINUE HANDLER FOR NOT FOUND SET done3 = TRUE;


					OPEN cur3;

					
					read_loop3: LOOP

						FETCH cur3 INTO tstart_tw,tstop_tw;

						IF done3 THEN
							LEAVE read_loop3;
						END IF;


                        
                        IF tstop_tw >= time_start_run AND tstart_tw <= time_stop_run THEN

							
							SET good_time_window = FALSE;

                        END IF;

					END LOOP;

					CLOSE cur3;

				END;


					
						
							
							

                    IF  aggregation_id = 1 THEN

						SET analysis_session_dir = concat(basedir_results,instrument_name,'/DR',datarepository_name,'_O',NEW.observationid,'/',analysistype_shortname,'_',analysissessiontype_shortname,'/T',time_start_run,'_',time_stop_run,'/');

						
						INSERT INTO analysissession (analysissessiontype_observationid,tstart,tstop,status,diroutputresults,type) VALUES (analysissessiontype_observation_id,time_start_run,time_stop_run,0,analysis_session_dir,0);

                        SET analysissession_id = LAST_INSERT_ID();


						

                        BEGIN

							DECLARE done4 INT DEFAULT FALSE;
                            DECLARE energybin_id INT UNSIGNED;
                            DECLARE b_obs DOUBLE;
                            DECLARE l_obs DOUBLE;
                            DECLARE e_min DOUBLE;
                            DECLARE e_max DOUBLE;
                            DECLARE run_status INT;

							DECLARE cur4 CURSOR FOR SELECT eb.energybinid FROM energybin eb WHERE eb.energybingroupid = energybingroup_id;
							DECLARE CONTINUE HANDLER FOR NOT FOUND SET done4 = TRUE;


							OPEN cur4;

							
							read_loop4: LOOP

								FETCH cur4 INTO energybin_id;


								IF done4 THEN
									LEAVE read_loop4;
								END IF;

								SELECT emin,emax INTO e_min,e_max FROM energybin WHERE energybinid = energybin_id;



                
								IF skyposition_type = 1 THEN


									SELECT l,b INTO l_obs,b_obs FROM observation where observationid = NEW.observationid;


									SET run_status = 2;
                    
										
										
									IF good_time_window IS FALSE THEN
										SET run_status = 1;
									END IF;

                                    IF time_stop_run > min_tstop_all OR time_start_run < max_tstart_all THEN
										SET run_status = 1;
									END IF;

                                  	SET run_dir = concat(basedir_run,instrument_name,'/DR',datarepository_name,'_O',NEW.observationid,'/',analysistype_shortname,'_',analysissessiontype_shortname,'/T',time_start_run,'_',time_stop_run,'_E',e_min,'_',e_max,'_P',l_obs,'_',b_obs,'/');

									
									INSERT INTO run (analysissessionid,tstart,tstop,status,l,b,r,energybinid,diroutputrun) VALUES (analysissession_id,time_start_run,time_stop_run,run_status,l_obs,b_obs,analysis_radius,energybin_id,run_dir);



                                END IF;

								
								IF skyposition_type = 10 THEN


									BEGIN

										DECLARE done5 INT DEFAULT FALSE;
										DECLARE skyring_id INT UNSIGNED;
                                        DECLARE ring_l DOUBLE;
                                        DECLARE ring_b DOUBLE;
                                        DECLARE ring_radius DOUBLE;

										DECLARE cur5 CURSOR FOR SELECT sr.skyringid,sr.l,sr.b,sr.radius FROM skyring sr WHERE sr.skyringgroupid = skyringgroup_id;
										DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5 = TRUE;

										OPEN cur5;

										
										read_loop5: LOOP

											FETCH cur5 INTO skyring_id,ring_l,ring_b,ring_radius;

											IF done5 THEN
												LEAVE read_loop5;
											END IF;


											SET run_status = 2;
											
												
												
											IF good_time_window IS FALSE THEN
												SET run_status = 1;
											END IF;


											IF time_stop_run > min_tstop_all OR time_start_run < max_tstart_all THEN
												SET run_status = 1;
											END IF;

											SET run_dir = concat(basedir_run,instrument_name,'/DR',datarepository_name,'_O',NEW.observationid,'/',analysistype_shortname,'_',analysissessiontype_shortname,'/T',time_start_run,'_',time_stop_run,'_E',e_min,'_',e_max,'_P',ring_l,'_',ring_b,'/');

                                            
                                            INSERT INTO run (analysissessionid,tstart,tstop,status,skyringid,energybinid,diroutputrun,l,b,r) VALUES (analysissession_id,time_start_run,time_stop_run,run_status,skyring_id,energybin_id,run_dir,ring_l,ring_b,analysis_radius);


										END LOOP;

										CLOSE cur5;

                                    END; 

                                END IF; 

							END LOOP;

							CLOSE cur4;

						END; 

					END IF; 

                
				IF timebinsize_seconds = -1 THEN
					SET time_stop_run = time_stop_run + 1; 
                ELSEIF timebinsize_seconds = -2 THEN
					SET time_stop_run = time_stop_run + timestep_seconds ;
                ELSE
                	SET time_start_run = time_start_run + timestep_seconds;
					SET time_stop_run = time_start_run + timebinsize_seconds;
                END IF;


				

            END WHILE;

		END LOOP;

		CLOSE cur1;


END */;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`188.15.168.50` */ /*!50003 TRIGGER `datarepository_update_check_run` AFTER UPDATE ON `observation_to_datarepository` FOR EACH ROW trigger_label: BEGIN


		IF NEW.tenddata != OLD.tenddata THEN

			
			BEGIN


				DECLARE run_id INT UNSIGNED;
                DECLARE min_endtime DOUBLE;
                DECLARE max_bin_size DOUBLE;
                DECLARE trun_start DOUBLE;
                DECLARE analysissessiontype_id INT UNSIGNED;
                DECLARE trun_stop DOUBLE;
				DECLARE done INT DEFAULT FALSE;
				DECLARE cur1 CURSOR FOR  SELECT runid,ast.maxbinsize,r.tstart,anstn.analysissessiontypeid FROM run r JOIN analysissession ans ON (ans.analysissessionid = r.analysissessionid)
                JOIN analysissessiontype_notice_observation anstno ON (anstno.analysissessiontype_notice_observationid = ans.analysissessiontype_notice_observationid) JOIN analysissessiontype_notice anstn ON (anstno.analysissessiontype_noticeid = anstn.analysissessiontype_noticeid) JOIN analysissessiontype ast ON (ast.analysissessiontypeid = anstn.analysissessiontypeid)  WHERE anstno.observationid = NEW.observationid and r.status = 1
                AND r.tstart >= (SELECT MAX(otdr.tstartdata) as 'max_starttime' from datarepository dr JOIN observation_to_datarepository otdr ON (otdr.datarepositoryid = dr.datarepositoryid) join dataprocessingtool_datatype_input dpt  on (dr.datatypeid = dpt.datatypeid ) join analysistype ant on(dpt.dataprocessingtoolid = ant.dataprocessingtoolid) join analysissessiontype ast on(ast.analysistypeid = ant.analysistypeid )
						WHERE ast.analysissessiontypeid = anstn.analysissessiontypeid  and otdr.observationid = NEW.observationid and  dr.active=1 and dpt.required = 1)
				AND r.tstart + ast.minbinsize <=  (SELECT MIN(otdr.tenddata) as 'min_endtime' from datarepository dr JOIN observation_to_datarepository otdr ON (otdr.datarepositoryid = dr.datarepositoryid) join dataprocessingtool_datatype_input dpt  on (dr.datatypeid = dpt.datatypeid ) join analysistype ant on(dpt.dataprocessingtoolid = ant.dataprocessingtoolid) join analysissessiontype ast on(ast.analysistypeid = ant.analysistypeid )
						WHERE ast.analysissessiontypeid = anstn.analysissessiontypeid and otdr.observationid = NEW.observationid and dr.active=1 and dpt.required = 1);

				DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

				OPEN cur1;


				read_loop: LOOP

					FETCH cur1 INTO run_id,max_bin_size,trun_start,analysissessiontype_id;

					IF done THEN
						LEAVE read_loop;
					END IF;

                    SELECT MIN(otdr.tenddata) INTO min_endtime from datarepository dr JOIN observation_to_datarepository otdr ON (otdr.datarepositoryid = dr.datarepositoryid) join dataprocessingtool_datatype_input dpt  on (dr.datatypeid = dpt.datatypeid ) join analysistype ant on(dpt.dataprocessingtoolid = ant.dataprocessingtoolid) join analysissessiontype ast on(ast.analysistypeid = ant.analysistypeid )
					WHERE ast.analysissessiontypeid = analysissessiontype_id and otdr.observationid = NEW.observationid and dr.active=1 and dpt.required = 1;

                    IF (max_bin_size > 0 AND trun_start +  max_bin_size <= min_endtime ) THEN
                       UPDATE run SET status = -3 WHERE runid = run_id;
                    ELSE
                       UPDATE run SET status = 2 WHERE runid = run_id;
                    END IF ;



				END LOOP;

				CLOSE cur1;

            END;


            
			BEGIN

				DECLARE run_id INT UNSIGNED;
                DECLARE trun_start DOUBLE;
                DECLARE trun_stop DOUBLE;
				DECLARE done INT DEFAULT FALSE;
				DECLARE cur1 CURSOR FOR  SELECT runid FROM run r JOIN analysissession ans ON (ans.analysissessionid = r.analysissessionid)
                JOIN analysissessiontype_observation ansto ON (ansto.analysissessiontype_observationid = ans.analysissessiontype_observationid) JOIN analysissessiontype ast ON (ast.analysissessiontypeid = ansto.analysissessiontypeid) WHERE ansto.observationid = NEW.observationid and r.status = 1
                AND r.tstart >= (SELECT MAX(otdr.tstartdata) as 'max_starttime' from datarepository dr JOIN observation_to_datarepository otdr ON (otdr.datarepositoryid = dr.datarepositoryid) join dataprocessingtool_datatype_input dpt  on (dr.datatypeid = dpt.datatypeid ) join analysistype ant on(dpt.dataprocessingtoolid = ant.dataprocessingtoolid) join analysissessiontype ast on(ast.analysistypeid = ant.analysistypeid )
						WHERE ast.analysissessiontypeid = ansto.analysissessiontypeid and otdr.observationid = NEW.observationid and dr.active=1 and dpt.required = 1)
				AND r.tstop <=  (SELECT MIN(otdr.tenddata) as 'min_endtime' from datarepository dr JOIN observation_to_datarepository otdr ON (otdr.datarepositoryid = dr.datarepositoryid) join dataprocessingtool_datatype_input dpt  on (dr.datatypeid = dpt.datatypeid ) join analysistype ant on(dpt.dataprocessingtoolid = ant.dataprocessingtoolid) join analysissessiontype ast on(ast.analysistypeid = ant.analysistypeid )
						WHERE ast.analysissessiontypeid = ansto.analysissessiontypeid and otdr.observationid = NEW.observationid  and dr.active=1 and dpt.required = 1) ;

				DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

				OPEN cur1;


				read_loop: LOOP

					FETCH cur1 INTO run_id;

					IF done THEN
						LEAVE read_loop;
					END IF;

                    UPDATE run SET status = 2 WHERE runid = run_id;

				END LOOP;

				CLOSE cur1;

            END;

		END IF; 

END */;;
/*!50003 SET SESSION SQL_MODE="NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`rt`@`%` */ /*!50003 TRIGGER `observation_to_datarepository_update` AFTER UPDATE ON `observation_to_datarepository` FOR EACH ROW IF    (OLD.tenddata < NEW.tenddata) THEN 

	trigger_label: BEGIN

			
			

			DECLARE done INT DEFAULT FALSE;
			DECLARE analysissessiontype_notice_id  INT UNSIGNED;

			DECLARE cur1 CURSOR FOR SELECT analysissessiontype_noticeid FROM analysissessiontype_notice anstn JOIN notice n ON (n.noticeid = anstn.noticeid) JOIN analysissessiontype anst ON (anst.analysissessiontypeid = anstn.analysissessiontypeid)
			JOIN analysistype ant ON (ant.analysistypeid = anst.analysistypeid) JOIN dataprocessingtool dpt ON (dpt.dataprocessingtoolid = ant.dataprocessingtoolid)
			JOIN dataprocessingtool_datatype_input dptdti ON (dptdti.dataprocessingtoolid=dpt.dataprocessingtoolid) WHERE n.noticetime > "2019-04-05T12:00:00" AND  dptdti.type = 1
			AND dptdti.datatypeid = (SELECT datatypeid FROM datarepository dr WHERE dr.datarepositoryid = NEW.datarepositoryid)
			AND NEW.tstartdata <= anstn.tstop AND NEW.tenddata >= anstn.tstart
            AND analysissessiontype_noticeid NOT IN ( SELECT analysissessiontype_noticeid FROM analysissessiontype_notice_observation astno WHERE astno.observationid = NEW.observationid);

			DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

			INSERT INTO log SELECT now(), concat('update observation to datarepository');

			OPEN cur1;

			read_loop: LOOP

				FETCH cur1 INTO analysissessiontype_notice_id;


				IF done THEN
					LEAVE read_loop;
				END IF;

				INSERT INTO log SELECT now(), concat('create new analysissessiontype_notice_observation');

				INSERT INTO analysissessiontype_notice_observation (analysissessiontype_noticeid,observationid,active) VALUES (analysissessiontype_notice_id,NEW.observationid,1);

			END LOOP;

			CLOSE cur1;


	END;

END IF */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# Dump of table observationwindowstatus
# ------------------------------------------------------------

DROP TABLE IF EXISTS `observationwindowstatus`;

CREATE TABLE `observationwindowstatus` (
  `observationgtiid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `observationid` int(10) unsigned NOT NULL,
  `gtinum` int(11) NOT NULL,
  `tstart` double DEFAULT NULL,
  `tstop` double DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `dataqualityindex` int(11) DEFAULT NULL,
  `instrumentstatusindex` int(11) DEFAULT NULL,
  `nsbIndex` int(11) DEFAULT NULL,
  `skyqualityindex` int(11) DEFAULT NULL,
  PRIMARY KEY (`observationgtiid`),
  UNIQUE KEY `observationid` (`observationid`,`gtinum`),
  CONSTRAINT `observationgtiibfk1` FOREIGN KEY (`observationid`) REFERENCES `observation` (`observationid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table observatoryinstrument_produce_datatype
# ------------------------------------------------------------

DROP TABLE IF EXISTS `observatoryinstrument_produce_datatype`;

CREATE TABLE `observatoryinstrument_produce_datatype` (
  `datatypeid` int(10) unsigned NOT NULL,
  `instrumentid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`instrumentid`,`datatypeid`),
  KEY `observatoryinstrumentproducedatatypeibfk1` (`datatypeid`),
  CONSTRAINT `observatoryinstrument_produce_datatype_ibfk_1` FOREIGN KEY (`instrumentid`) REFERENCES `instrument` (`instrumentid`) ON UPDATE CASCADE,
  CONSTRAINT `observatoryinstrumentproducedatatypeibfk1` FOREIGN KEY (`datatypeid`) REFERENCES `datatype` (`datatypeid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table observingmode
# ------------------------------------------------------------

DROP TABLE IF EXISTS `observingmode`;

CREATE TABLE `observingmode` (
  `observingmodeid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `instrumentid` int(10) unsigned NOT NULL,
  `zenithangle` double DEFAULT NULL,
  `minskyquality` int(11) DEFAULT NULL,
  `minnsb` int(11) DEFAULT NULL,
  `maxnsb` int(11) DEFAULT NULL,
  PRIMARY KEY (`observingmodeid`),
  KEY `instrumentid` (`instrumentid`),
  CONSTRAINT `observingmode_ibfk_1` FOREIGN KEY (`instrumentid`) REFERENCES `instrument` (`instrumentid`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `observingmode` WRITE;
/*!40000 ALTER TABLE `observingmode` DISABLE KEYS */;

INSERT INTO `observingmode` (`observingmodeid`, `instrumentid`, `zenithangle`, `minskyquality`, `minnsb`, `maxnsb`)
VALUES
	(1,9,NULL,NULL,NULL,NULL);

/*!40000 ALTER TABLE `observingmode` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table postanalysis
# ------------------------------------------------------------

DROP TABLE IF EXISTS `postanalysis`;

CREATE TABLE `postanalysis` (
  `postanalysisid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(128) NOT NULL,
  `shortname` char(15) NOT NULL,
  `ncpu` int(11) NOT NULL,
  `task` text NOT NULL,
  `metaconffile` text NOT NULL,
  `queue` char(128) NOT NULL DEFAULT '',
  `reservation` varchar(128) NOT NULL,
  `type` int(11) NOT NULL,
  `module` text NOT NULL,
  PRIMARY KEY (`postanalysisid`),
  UNIQUE KEY `shortname` (`shortname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `postanalysis` WRITE;
/*!40000 ALTER TABLE `postanalysis` DISABLE KEYS */;

INSERT INTO `postanalysis` (`postanalysisid`, `name`, `shortname`, `ncpu`, `task`, `metaconffile`, `queue`, `reservation`, `type`, `module`)
VALUES
	(1,'MCAL_import_results','mcal_import',1,'source /opt/module/mcal_pipe_2.0\nsource activate py_mcal_27\nsource /opt/module/agile-B24-r5\nsource /opt/module/agile-mcal\n\npython $MCALPIPE/classes/ImportResults.py 1 session.xml','<session id=\"#@analysissessionid@#\" runid=\"#@runid@#\" >\n        <parameter name=\"DirectoryList\" results=\"#@diroutputresults@#\" />\n</session>','fast','fast_rt',0,'');

/*!40000 ALTER TABLE `postanalysis` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table proposal
# ------------------------------------------------------------

DROP TABLE IF EXISTS `proposal`;

CREATE TABLE `proposal` (
  `proposalid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(128) DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`proposalid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `proposal` WRITE;
/*!40000 ALTER TABLE `proposal` DISABLE KEYS */;

INSERT INTO `proposal` (`proposalid`, `name`, `description`)
VALUES
	(1,NULL,'AGILE_OBS');

/*!40000 ALTER TABLE `proposal` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table receivedsciencealert
# ------------------------------------------------------------

DROP TABLE IF EXISTS `receivedsciencealert`;

CREATE TABLE `receivedsciencealert` (
  `receivedsciencealertid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `instrumentid` int(10) unsigned NOT NULL,
  `triggerid` bigint(14) unsigned NOT NULL,
  `networkid` int(10) unsigned NOT NULL,
  `time` double NOT NULL,
  `ste` int(11) DEFAULT '0',
  `internal` int(11) DEFAULT '0',
  PRIMARY KEY (`receivedsciencealertid`),
  UNIQUE KEY `instrumentid` (`instrumentid`,`triggerid`),
  KEY `networkid` (`networkid`),
  CONSTRAINT `receivedsciencealert_ibfk_1` FOREIGN KEY (`instrumentid`) REFERENCES `instrument` (`instrumentid`) ON UPDATE CASCADE,
  CONSTRAINT `receivedsciencealert_ibfk_2` FOREIGN KEY (`networkid`) REFERENCES `network` (`networkid`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `receivedsciencealert` WRITE;
/*!40000 ALTER TABLE `receivedsciencealert` DISABLE KEYS */;

INSERT INTO `receivedsciencealert` (`receivedsciencealertid`, `instrumentid`, `triggerid`, `networkid`, `time`, `ste`, `internal`)
VALUES
	(6376,0,0,1,579846930,0,NULL);

/*!40000 ALTER TABLE `receivedsciencealert` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table run
# ------------------------------------------------------------

DROP TABLE IF EXISTS `run`;

CREATE TABLE `run` (
  `runid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `analysissessionid` int(10) unsigned NOT NULL,
  `tsubmit` double DEFAULT NULL,
  `tstart_job` double DEFAULT NULL,
  `timesuspended` double DEFAULT NULL,
  `tstop_job` double DEFAULT NULL,
  `tstart` double DEFAULT NULL,
  `tstop` double DEFAULT NULL,
  `status` int(11) NOT NULL,
  `exitcode` int(11) DEFAULT NULL,
  `jobidscheduler` int(11) DEFAULT NULL,
  `l` double DEFAULT NULL,
  `b` double DEFAULT NULL,
  `r` double DEFAULT NULL,
  `skyringid` int(10) unsigned DEFAULT NULL,
  `energybinid` int(10) unsigned DEFAULT NULL,
  `conf` text,
  `command` text,
  `diroutputrun` text,
  `postanalysisid` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`runid`),
  KEY `postanalysisid` (`postanalysisid`),
  KEY `analysissessionid` (`analysissessionid`),
  KEY `skyringid` (`skyringid`),
  KEY `energybinid` (`energybinid`),
  KEY `status` (`status`),
  CONSTRAINT `run_ibfk_1` FOREIGN KEY (`skyringid`) REFERENCES `skyring` (`skyringid`) ON UPDATE CASCADE,
  CONSTRAINT `run_ibfk_2` FOREIGN KEY (`energybinid`) REFERENCES `energybin` (`energybinid`) ON UPDATE CASCADE,
  CONSTRAINT `runibfk1` FOREIGN KEY (`postanalysisid`) REFERENCES `postanalysis` (`postanalysisid`) ON DELETE CASCADE,
  CONSTRAINT `runibfk3` FOREIGN KEY (`analysissessionid`) REFERENCES `analysissession` (`analysissessionid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table run_queued
# ------------------------------------------------------------

DROP VIEW IF EXISTS `run_queued`;

CREATE TABLE `run_queued` (
   `runid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `status` INT(11) NOT NULL,
   `postanalysisid` INT(10) UNSIGNED NULL DEFAULT NULL,
   `analysissessionid` INT(10) UNSIGNED NOT NULL,
   `jobidscheduler` INT(11) NULL DEFAULT NULL,
   `tstart` DOUBLE NULL DEFAULT NULL,
   `tstop` DOUBLE NULL DEFAULT NULL,
   `r_l` DOUBLE NULL DEFAULT NULL,
   `r_b` DOUBLE NULL DEFAULT NULL
) ENGINE=MyISAM;



# Dump of table run_runnable_noticetrigger
# ------------------------------------------------------------

DROP VIEW IF EXISTS `run_runnable_noticetrigger`;

CREATE TABLE `run_runnable_noticetrigger` (
   `ant_sname` VARCHAR(100) NOT NULL DEFAULT '',
   `anst_sname` VARCHAR(100) NOT NULL DEFAULT '',
   `observationid` INT(10) UNSIGNED NOT NULL,
   `runid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `tstart` DOUBLE NULL DEFAULT NULL,
   `tstop` DOUBLE NULL DEFAULT NULL,
   `l` DOUBLE NULL DEFAULT NULL,
   `b` DOUBLE NULL DEFAULT NULL,
   `radius` DOUBLE NULL DEFAULT NULL,
   `diroutputrun` TEXT NULL DEFAULT NULL,
   `diroutputresults` TEXT NULL DEFAULT NULL,
   `deleterun` TINYINT(1) NOT NULL,
   `reservation` VARCHAR(128) NOT NULL,
   `queue` VARCHAR(128) NOT NULL DEFAULT '',
   `submit_priority` INT(11) NOT NULL,
   `metaconffile` TEXT NULL DEFAULT NULL,
   `task` TEXT NULL DEFAULT NULL,
   `module` TEXT NOT NULL,
   `emin` DOUBLE NULL DEFAULT NULL,
   `emax` DOUBLE NULL DEFAULT NULL,
   `skypositiontype` INT(1) NULL DEFAULT NULL,
   `skyrefname` CHAR(10) NOT NULL DEFAULT '',
   `skyrefunit` VARCHAR(10) NOT NULL DEFAULT '',
   `timerefname` CHAR(128) NOT NULL DEFAULT '',
   `timerefunit` VARCHAR(10) NOT NULL DEFAULT '',
   `contour` MEDIUMTEXT NOT NULL,
   `notice_xml` TEXT NULL DEFAULT NULL,
   `ligo_map_url` VARCHAR(255) NULL DEFAULT NULL,
   `notice_type` INT(11) NULL DEFAULT NULL,
   `seqnum` INT(11) NOT NULL,
   `n_radius` DOUBLE NOT NULL,
   `targetxml` TEXT NULL DEFAULT NULL,
   `targetid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `obs_l` DOUBLE NOT NULL,
   `obs_b` DOUBLE NOT NULL,
   `analysisradius` DOUBLE NULL DEFAULT NULL,
   `fov` DOUBLE NULL DEFAULT NULL,
   `alert_instr_name` VARCHAR(128) NOT NULL DEFAULT '',
   `tzero` DOUBLE NOT NULL,
   `triggerid` BIGINT(14) UNSIGNED NOT NULL
) ENGINE=MyISAM;



# Dump of table run_runnable_observationtrigger
# ------------------------------------------------------------

DROP VIEW IF EXISTS `run_runnable_observationtrigger`;

CREATE TABLE `run_runnable_observationtrigger` (
   `observationid` INT(10) UNSIGNED NOT NULL,
   `runid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `tstart` DOUBLE NULL DEFAULT NULL,
   `radius` DOUBLE NULL DEFAULT NULL,
   `tstop` DOUBLE NULL DEFAULT NULL,
   `l` DOUBLE NULL DEFAULT NULL,
   `b` DOUBLE NULL DEFAULT NULL,
   `diroutputrun` TEXT NULL DEFAULT NULL,
   `diroutputresults` TEXT NULL DEFAULT NULL,
   `deleterun` TINYINT(1) NOT NULL,
   `reservation` VARCHAR(128) NOT NULL,
   `queue` VARCHAR(128) NOT NULL DEFAULT '',
   `submit_priority` INT(11) NOT NULL,
   `metaconffile` TEXT NULL DEFAULT NULL,
   `task` TEXT NULL DEFAULT NULL,
   `module` TEXT NOT NULL,
   `emin` DOUBLE NULL DEFAULT NULL,
   `emax` DOUBLE NULL DEFAULT NULL,
   `skypositiontype` INT(1) NULL DEFAULT NULL,
   `skyrefname` CHAR(10) NOT NULL DEFAULT '',
   `skyrefunit` VARCHAR(10) NOT NULL DEFAULT '',
   `timerefname` CHAR(128) NOT NULL DEFAULT '',
   `timerefunit` VARCHAR(10) NOT NULL DEFAULT '',
   `targetxml` TEXT NULL DEFAULT NULL,
   `targetid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `obs_l` DOUBLE NOT NULL,
   `obs_b` DOUBLE NOT NULL,
   `analysisradius` DOUBLE NULL DEFAULT NULL,
   `fov` DOUBLE NULL DEFAULT NULL
) ENGINE=MyISAM;



# Dump of table run_runnable_postanalyis
# ------------------------------------------------------------

DROP VIEW IF EXISTS `run_runnable_postanalyis`;

CREATE TABLE `run_runnable_postanalyis` (
   `runid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `diroutputresults` TEXT NULL DEFAULT NULL,
   `analysissessionid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `postanalysisid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `name` CHAR(128) NOT NULL,
   `shortname` CHAR(15) NOT NULL,
   `ncpu` INT(11) NOT NULL,
   `task` TEXT NOT NULL,
   `metaconffile` TEXT NOT NULL,
   `queue` CHAR(128) NOT NULL DEFAULT '',
   `reservation` VARCHAR(128) NOT NULL,
   `type` INT(11) NOT NULL,
   `module` TEXT NOT NULL
) ENGINE=MyISAM;



# Dump of table run_running
# ------------------------------------------------------------

DROP VIEW IF EXISTS `run_running`;

CREATE TABLE `run_running` (
   `runid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `status` INT(11) NOT NULL,
   `postanalysisid` INT(10) UNSIGNED NULL DEFAULT NULL,
   `analysissessionid` INT(10) UNSIGNED NOT NULL,
   `jobidscheduler` INT(11) NULL DEFAULT NULL,
   `tstart` DOUBLE NULL DEFAULT NULL,
   `tstop` DOUBLE NULL DEFAULT NULL,
   `r_l` DOUBLE NULL DEFAULT NULL,
   `r_b` DOUBLE NULL DEFAULT NULL
) ENGINE=MyISAM;



# Dump of table run_suspended
# ------------------------------------------------------------

DROP VIEW IF EXISTS `run_suspended`;

CREATE TABLE `run_suspended` (
   `runid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `status` INT(11) NOT NULL,
   `postanalysisid` INT(10) UNSIGNED NULL DEFAULT NULL,
   `analysissessionid` INT(10) UNSIGNED NOT NULL,
   `jobidscheduler` INT(11) NULL DEFAULT NULL,
   `tstart` DOUBLE NULL DEFAULT NULL,
   `tstop` DOUBLE NULL DEFAULT NULL
) ENGINE=MyISAM;



# Dump of table run_to_cancel
# ------------------------------------------------------------

DROP VIEW IF EXISTS `run_to_cancel`;

CREATE TABLE `run_to_cancel` (
   `runid` INT(10) UNSIGNED NOT NULL DEFAULT '0',
   `status` INT(11) NOT NULL,
   `postanalysisid` INT(10) UNSIGNED NULL DEFAULT NULL,
   `analysissessionid` INT(10) UNSIGNED NOT NULL,
   `jobidscheduler` INT(11) NULL DEFAULT NULL,
   `tstart` DOUBLE NULL DEFAULT NULL,
   `tstop` DOUBLE NULL DEFAULT NULL
) ENGINE=MyISAM;



# Dump of table skyreftype
# ------------------------------------------------------------

DROP TABLE IF EXISTS `skyreftype`;

CREATE TABLE `skyreftype` (
  `skyreftypeid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(10) NOT NULL DEFAULT '',
  `unit` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`skyreftypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `skyreftype` WRITE;
/*!40000 ALTER TABLE `skyreftype` DISABLE KEYS */;

INSERT INTO `skyreftype` (`skyreftypeid`, `name`, `unit`)
VALUES
	(1,'galactic','deg'),
	(2,'fk5','deg');

/*!40000 ALTER TABLE `skyreftype` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table skyring
# ------------------------------------------------------------

DROP TABLE IF EXISTS `skyring`;

CREATE TABLE `skyring` (
  `skyringid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `skyringgroupid` int(10) unsigned NOT NULL,
  `l` double NOT NULL,
  `b` double NOT NULL,
  `radius` double NOT NULL,
  `number` int(11) NOT NULL,
  PRIMARY KEY (`skyringid`),
  UNIQUE KEY `skyringgroupid_2` (`skyringgroupid`,`number`),
  KEY `skyringgroupid` (`skyringgroupid`),
  CONSTRAINT `skyringibfk1` FOREIGN KEY (`skyringgroupid`) REFERENCES `skyringgroup` (`skyringgroupid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table skyringgroup
# ------------------------------------------------------------

DROP TABLE IF EXISTS `skyringgroup`;

CREATE TABLE `skyringgroup` (
  `skyringgroupid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `shortname` char(15) NOT NULL,
  `description` text,
  `skyreftypeid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`skyringgroupid`),
  UNIQUE KEY `shortname` (`shortname`),
  KEY `skyreftypeid` (`skyreftypeid`),
  CONSTRAINT `skyringgroupibfk1` FOREIGN KEY (`skyreftypeid`) REFERENCES `skyreftype` (`skyreftypeid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table target
# ------------------------------------------------------------

DROP TABLE IF EXISTS `target`;

CREATE TABLE `target` (
  `targetid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `targetcode` int(11) NOT NULL,
  `proposalid` int(10) unsigned NOT NULL,
  `observingmodeid` int(10) unsigned NOT NULL,
  `name` text,
  `l` double DEFAULT NULL,
  `b` double DEFAULT NULL,
  `xmlmodel` text,
  `emin` double DEFAULT NULL,
  `emax` double DEFAULT NULL,
  PRIMARY KEY (`targetid`),
  UNIQUE KEY `targetcode` (`targetcode`,`proposalid`),
  KEY `proposalid` (`proposalid`),
  KEY `observingmodeid` (`observingmodeid`),
  CONSTRAINT `targetibfk1` FOREIGN KEY (`proposalid`) REFERENCES `proposal` (`proposalid`) ON DELETE CASCADE,
  CONSTRAINT `targetibfk2` FOREIGN KEY (`observingmodeid`) REFERENCES `observingmode` (`observingmodeid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `target` WRITE;
/*!40000 ALTER TABLE `target` DISABLE KEYS */;

INSERT INTO `target` (`targetid`, `targetcode`, `proposalid`, `observingmodeid`, `name`, `l`, `b`, `xmlmodel`, `emin`, `emax`)
VALUES
	(1,0,1,1,NULL,0,0,NULL,0,10000);

/*!40000 ALTER TABLE `target` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table temp
# ------------------------------------------------------------

DROP TABLE IF EXISTS `temp`;

CREATE TABLE `temp` (
  `analysissessiontypeid` int(10) unsigned NOT NULL DEFAULT '0',
  `name` varchar(128) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `shortname` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `aggregation` int(11) NOT NULL,
  `description` text CHARACTER SET utf8,
  `analysistypeid` int(10) unsigned NOT NULL,
  `analysistriggerid` int(10) unsigned NOT NULL,
  `deltatstart` int(11) NOT NULL,
  `deltatstop` int(11) NOT NULL,
  `timebinsize` double NOT NULL,
  `minbinsize` double NOT NULL,
  `maxbinsize` double NOT NULL,
  `timestep` double NOT NULL,
  `runnable` int(1) NOT NULL,
  `queue` varchar(128) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `reservation` varchar(128) CHARACTER SET utf8 NOT NULL,
  `energybingroupid` int(10) unsigned DEFAULT NULL,
  `skypositiontype` int(1) DEFAULT NULL,
  `skyringgroupid` int(10) unsigned DEFAULT NULL,
  `analysisradius` double DEFAULT NULL,
  `postanalysisid` int(10) unsigned DEFAULT NULL,
  `submit_priority` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `temp` WRITE;
/*!40000 ALTER TABLE `temp` DISABLE KEYS */;

INSERT INTO `temp` (`analysissessiontypeid`, `name`, `shortname`, `aggregation`, `description`, `analysistypeid`, `analysistriggerid`, `deltatstart`, `deltatstop`, `timebinsize`, `minbinsize`, `maxbinsize`, `timestep`, `runnable`, `queue`, `reservation`, `energybingroupid`, `skypositiontype`, `skyringgroupid`, `analysisradius`, `postanalysisid`, `submit_priority`)
VALUES
	(1,'Fermi-GBM_MCAL-ALERT','Fermi-GBM_mcal_alert_full',1,NULL,2,2,-1000,1000,2000,2000,0,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(2,'Fermi-GBM_MCAL-ALERT-partial-coverage','Fermi-GBM_mcal_alert_partial',1,NULL,2,2,-1000,1000,2000,0,2000,2000,1,'fast','fast_rt',1,4,NULL,180,1,1),
	(3,'Fermi-GBM-GRB-5s','Fermi-GBM_GRB_5s',1,NULL,4,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(4,'Fermi-GBM-GW-1000s','Fermi-GBM_GW_1000s',1,NULL,6,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(5,'Fermi-GBM-GRB-100s','Fermi-GBM_GRB_100s',1,NULL,4,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(6,'Fermi-GBM-GRB-1000s','Fermi-GBM_GRB_1000s',1,NULL,4,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(7,'Fermi-GBM-visCheckAux','Fermi-GBM-visCheckAux',1,NULL,7,2,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(8,'Fermi-GBM-ratemeters','Fermi-GBM-ratemeters',1,NULL,8,2,-500,500,1000,1000,0,1000,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(9,'Fermi-GBM-ATstatus','Fermi-GBM-ATstatus',1,NULL,9,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(19,'Fermi-GBM-aitoff-e10-e50000-1000s','Fermi-GBM-aitoff-e10-e50000-1000s',1,NULL,10,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(20,'Fermi-GBM-spot6-e10-e50000-1000s','Fermi-GBM-spot6-e10-e50000-1000s',1,NULL,11,2,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(27,'Fermi-GBM-GRB-10s','Fermi-GBM_GRB_10s',1,NULL,4,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(28,'Fermi-GBM-GW-100s','Fermi-GBM_GW_100s',1,NULL,6,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(29,'Fermi-GBM-GW-10s','Fermi-GBM_GW_10s',1,NULL,6,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(30,'Fermi-GBM-GW-5s','Fermi-GBM_GW_5s',1,NULL,6,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(50,'Fermi-GBM-aitoff-e10-e50000-100s','Fermi-GBM-aitoff-e10-e50000-100s',1,NULL,10,2,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(51,'Fermi-GBM-aitoff-e10-e50000-10s','Fermi-GBM-aitoff-e10-e50000-10s',1,NULL,10,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(52,'Fermi-GBM-aitoff-e10-e50000-5s','Fermi-GBM-aitoff-e10-e50000-5s',1,NULL,10,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(53,'Fermi-GBM_MCAL-PLOT','Fermi-GBM_MCAL-PLOT',1,NULL,12,2,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(57,'Fermi-GBM_GRID-UL-100s_FM3.119','Fermi-GBM_GRID-UL-100s_FM3.119',1,NULL,13,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(63,'Fermi-GBM_GRID-UL-10s_FM3.119','Fermi-GBM_GRID-UL-10s_FM3.119',1,NULL,13,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(64,'Fermi-GBM_GRID-UL-1000s_FM3.119','Fermi-GBM_GRID-UL-1000s_FM3.119',1,NULL,13,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(65,'Fermi-GBM_GRID-UL-5s_FM3.119','Fermi-GBM_GRID-UL-5s_FM3.119',1,NULL,13,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(176,'Fermi-GBM-FOV','Fermi-GBM-FOV',1,NULL,15,2,0,4,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(182,'Fermi-GBM-GRB-5s_FT3ab','Fermi-GBM_GRB_5s_FT3ab',1,NULL,16,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(183,'Fermi-GBM-GW-1000s_FT3ab','Fermi-GBM_GW_1000s_FT3ab',1,NULL,17,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(184,'Fermi-GBM-GRB-100s_FT3ab','Fermi-GBM_GRB_100s_FT3ab',1,NULL,16,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(185,'Fermi-GBM-GRB-1000s_FT3ab','Fermi-GBM_GRB_1000s_FT3ab',1,NULL,16,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(186,'Fermi-GBM-aitoff-e10-e50000-1000s_FT3ab','Fermi-GBM-aitoff-e10-e50000-1000s_FT3ab',1,NULL,18,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(187,'Fermi-GBM-spot6-e10-e50000-1000s_FT3ab','Fermi-GBM-spot6-e10-e50000-1000s_FT3ab',1,NULL,19,2,-1000,1000,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(188,'Fermi-GBM-GRB-10s_FT3ab','Fermi-GBM_GRB_10s_FT3ab',1,NULL,16,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(189,'Fermi-GBM-GW-100s_FT3ab','Fermi-GBM_GW_100s_FT3ab',1,NULL,17,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(190,'Fermi-GBM-GW-10s_FT3ab','Fermi-GBM_GW_10s_FT3ab',1,NULL,17,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(191,'Fermi-GBM-GW-5s_FT3ab','Fermi-GBM_GW_5s_FT3ab',1,NULL,17,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(192,'Fermi-GBM-aitoff-e10-e50000-100s_FT3ab','Fermi-GBM-aitoff-e10-e50000-100s_FT3ab',1,NULL,18,2,-1000,1000,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(193,'Fermi-GBM-aitoff-e10-e50000-10s_FT3ab','Fermi-GBM-aitoff-e10-e50000-10s_FT3ab',1,NULL,18,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(194,'Fermi-GBM-aitoff-e10-e50000-5s_FT3ab','Fermi-GBM-aitoff-e10-e50000-5s_FT3ab',1,NULL,18,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(195,'Fermi-GBM_GRID-UL-100s_FT3ab','Fermi-GBM_GRID-UL-100s_FT3ab',1,NULL,20,2,0,100,100,100,0,100,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(196,'Fermi-GBM_GRID-UL-10s_FT3ab','Fermi-GBM_GRID-UL-10s_FT3ab',1,NULL,20,2,0,10,10,10,0,10,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(197,'Fermi-GBM_GRID-UL-1000s_FT3ab','Fermi-GBM_GRID-UL-1000s_FT3ab',1,NULL,20,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(198,'Fermi-GBM_GRID-UL-5s_FT3ab','Fermi-GBM_GRID-UL-5s_FT3ab',1,NULL,20,2,0,5,5,5,0,5,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(359,'Fermi-GBM-GRB-5s_lm5','Fermi-GBM_GRB_5s_lm5',1,NULL,21,2,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(360,'Fermi-GBM-GW-1000s_lm5','Fermi-GBM_GW_1000s_lm5',1,NULL,23,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(361,'Fermi-GBM-GRB-100s_lm5','Fermi-GBM_GRB_100s_lm5',1,NULL,21,2,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(362,'Fermi-GBM-GRB-1000s_lm5','Fermi-GBM_GRB_1000s_lm5',1,NULL,21,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(367,'Fermi-GBM-GRB-10s_lm5','Fermi-GBM_GRB_10s_lm5',1,NULL,21,2,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(368,'Fermi-GBM-GW-100s_lm5','Fermi-GBM_GW_100s_lm5',1,NULL,23,2,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(369,'Fermi-GBM-GW-10s_lm5','Fermi-GBM_GW_10s_lm5',1,NULL,23,2,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(370,'Fermi-GBM-GW-5s_lm5','Fermi-GBM_GW_5s_lm5',1,NULL,23,2,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(395,'Fermi-GBM-GRB-5s_FT3ab_lm5','Fermi-GBM_GRB_5s_FT3ab_lm5',1,NULL,25,2,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(396,'Fermi-GBM-GW-1000s_FT3ab_lm5','Fermi-GBM_GW_1000s_FT3ab_lm5',1,NULL,26,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(397,'Fermi-GBM-GRB-100s_FT3ab_lm5','Fermi-GBM_GRB_100s_FT3ab_lm5',1,NULL,25,2,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(398,'Fermi-GBM-GRB-1000s_FT3ab_lm5','Fermi-GBM_GRB_1000s_FT3ab_lm5',1,NULL,25,2,0,1000,1000,1000,0,1000,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(399,'Fermi-GBM-GRB-10s_FT3ab_lm5','Fermi-GBM_GRB_10s_FT3ab_lm5',1,NULL,25,2,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(400,'Fermi-GBM-GW-100s_FT3ab_lm5','Fermi-GBM_GW_100s_FT3ab_lm5',1,NULL,26,2,0,100,100,100,0,100,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(401,'Fermi-GBM-GW-10s_FT3ab_lm5','Fermi-GBM_GW_10s_FT3ab_lm5',1,NULL,26,2,0,10,10,10,0,10,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(402,'Fermi-GBM-GW-5s_FT3ab_lm5','Fermi-GBM_GW_5s_FT3ab_lm5',1,NULL,26,2,0,5,5,5,0,5,0,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(666,'Fermi-GBM-GW--2+2s','Fermi-GBM_GW_-2+2s',1,NULL,6,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(667,'Fermi-GBM-GRB--2+2s','Fermi-GBM_GRB_-2+2s',1,NULL,4,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(669,'Fermi-GBM-aitoff-e10-e50000--2+2s','Fermi-GBM-aitoff-e10-e50000--2+2s',1,NULL,10,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(673,'Fermi-GBM_GRID-UL--2+2s_FM3.119','Fermi-GBM_GRID-UL--2+2s_FM3.119',1,NULL,13,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(682,'Fermi-GBM-GW--2+2s_FT3ab','Fermi-GBM_GW_-2+2s_FT3ab',1,NULL,17,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(683,'Fermi-GBM-GRB--2+2s_FT3ab','Fermi-GBM_GRB_-2+2s_FT3ab',1,NULL,16,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(684,'Fermi-GBM-aitoff-e10-e50000--2+2s_FT3ab','Fermi-GBM-aitoff-e10-e50000--2+2s_FT3ab',1,NULL,18,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0),
	(685,'Fermi-GBM_GRID-UL--2+2s_FT3ab','Fermi-GBM_GRID-UL--2+2s_FT3ab',1,NULL,20,2,-2,2,4,4,0,4,1,'fast','fast_rt',1,4,NULL,180,NULL,0);

/*!40000 ALTER TABLE `temp` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table timereftype
# ------------------------------------------------------------

DROP TABLE IF EXISTS `timereftype`;

CREATE TABLE `timereftype` (
  `timereftypeid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` char(128) NOT NULL DEFAULT '',
  `unit` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`timereftypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `timereftype` WRITE;
/*!40000 ALTER TABLE `timereftype` DISABLE KEYS */;

INSERT INTO `timereftype` (`timereftypeid`, `name`, `unit`)
VALUES
	(1,'mjd','day'),
	(2,'tt','s');

/*!40000 ALTER TABLE `timereftype` ENABLE KEYS */;
UNLOCK TABLES;




# Replace placeholder table for run_runnable_postanalyis with correct view syntax
# ------------------------------------------------------------

DROP TABLE `run_runnable_postanalyis`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`188.15.168.50` SQL SECURITY DEFINER VIEW `run_runnable_postanalyis`
AS SELECT
   `r`.`runid` AS `runid`,
   `ans`.`diroutputresults` AS `diroutputresults`,
   `ans`.`analysissessionid` AS `analysissessionid`,
   `pa`.`postanalysisid` AS `postanalysisid`,
   `pa`.`name` AS `name`,
   `pa`.`shortname` AS `shortname`,
   `pa`.`ncpu` AS `ncpu`,
   `pa`.`task` AS `task`,
   `pa`.`metaconffile` AS `metaconffile`,
   `pa`.`queue` AS `queue`,
   `pa`.`reservation` AS `reservation`,
   `pa`.`type` AS `type`,
   `pa`.`module` AS `module`
FROM ((`postanalysis` `pa` join `run` `r` on((`r`.`postanalysisid` = `pa`.`postanalysisid`))) join `analysissession` `ans` on((`ans`.`analysissessionid` = `r`.`analysissessionid`))) where (`r`.`status` = 2);


# Replace placeholder table for run_runnable_observationtrigger with correct view syntax
# ------------------------------------------------------------

DROP TABLE `run_runnable_observationtrigger`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`188.15.168.50` SQL SECURITY DEFINER VIEW `run_runnable_observationtrigger`
AS SELECT
   `ansto`.`observationid` AS `observationid`,
   `r`.`runid` AS `runid`,
   `r`.`tstart` AS `tstart`,
   `r`.`r` AS `radius`,
   `r`.`tstop` AS `tstop`,
   `r`.`l` AS `l`,
   `r`.`b` AS `b`,
   `r`.`diroutputrun` AS `diroutputrun`,
   `ans`.`diroutputresults` AS `diroutputresults`,
   `ant`.`deleterun` AS `deleterun`,
   `anst`.`reservation` AS `reservation`,
   `anst`.`queue` AS `queue`,
   `anst`.`submit_priority` AS `submit_priority`,
   `ant`.`metaconffile` AS `metaconffile`,
   `ant`.`task` AS `task`,
   `dpt`.`module` AS `module`,
   `eb`.`emin` AS `emin`,
   `eb`.`emax` AS `emax`,
   `anst`.`skypositiontype` AS `skypositiontype`,
   `skrt`.`name` AS `skyrefname`,
   `skrt`.`unit` AS `skyrefunit`,
   `trt`.`name` AS `timerefname`,
   `trt`.`unit` AS `timerefunit`,
   `ta`.`xmlmodel` AS `targetxml`,
   `ta`.`targetid` AS `targetid`,
   `obs`.`l` AS `obs_l`,
   `obs`.`b` AS `obs_b`,
   `anst`.`analysisradius` AS `analysisradius`,
   `inst`.`fov` AS `fov`
FROM (((((((((((((`run` `r` join `analysissession` `ans` on((`ans`.`analysissessionid` = `r`.`analysissessionid`))) join `analysissessiontype_observation` `ansto` on((`ansto`.`analysissessiontype_observationid` = `ans`.`analysissessiontype_observationid`))) join `analysissessiontype` `anst` on((`anst`.`analysissessiontypeid` = `ansto`.`analysissessiontypeid`))) join `analysistype` `ant` on((`ant`.`analysistypeid` = `anst`.`analysistypeid`))) join `dataprocessingtool` `dpt` on((`dpt`.`dataprocessingtoolid` = `ant`.`dataprocessingtoolid`))) join `energybin` `eb` on((`eb`.`energybinid` = `r`.`energybinid`))) join `skyreftype` `skrt` on((`skrt`.`skyreftypeid` = `dpt`.`skyreftypeid`))) join `timereftype` `trt` on((`trt`.`timereftypeid` = `dpt`.`timereftypeid`))) join `observation_target` `ota` on((`ota`.`observationid` = `ansto`.`observationid`))) join `target` `ta` on((`ta`.`targetid` = `ota`.`targetid`))) join `observation` `obs` on((`obs`.`observationid` = `ansto`.`observationid`))) join `observingmode` `obsm` on((`obsm`.`observingmodeid` = `ta`.`observingmodeid`))) join `instrument` `inst` on((`inst`.`instrumentid` = `obsm`.`instrumentid`))) where ((`r`.`status` = 2) and isnull(`r`.`postanalysisid`));


# Replace placeholder table for run_suspended with correct view syntax
# ------------------------------------------------------------

DROP TABLE `run_suspended`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`188.15.168.50` SQL SECURITY DEFINER VIEW `run_suspended`
AS SELECT
   `r`.`runid` AS `runid`,
   `r`.`status` AS `status`,
   `r`.`postanalysisid` AS `postanalysisid`,
   `r`.`analysissessionid` AS `analysissessionid`,
   `r`.`jobidscheduler` AS `jobidscheduler`,
   `r`.`tstart` AS `tstart`,
   `r`.`tstop` AS `tstop`
FROM `run` `r` where (`r`.`status` = -(102));


# Replace placeholder table for run_queued with correct view syntax
# ------------------------------------------------------------

DROP TABLE `run_queued`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`188.15.168.50` SQL SECURITY DEFINER VIEW `run_queued`
AS SELECT
   `r`.`runid` AS `runid`,
   `r`.`status` AS `status`,
   `r`.`postanalysisid` AS `postanalysisid`,
   `r`.`analysissessionid` AS `analysissessionid`,
   `r`.`jobidscheduler` AS `jobidscheduler`,
   `r`.`tstart` AS `tstart`,
   `r`.`tstop` AS `tstop`,
   `r`.`l` AS `r_l`,
   `r`.`b` AS `r_b`
FROM `run` `r` where (`r`.`status` = 3);


# Replace placeholder table for observation_parameters with correct view syntax
# ------------------------------------------------------------

DROP TABLE `observation_parameters`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`188.15.168.50` SQL SECURITY DEFINER VIEW `observation_parameters`
AS SELECT
   `o`.`observationid` AS `observationid`,
   `o`.`tstartplanned` AS `tstartplanned`,
   `o`.`tendplanned` AS `tendplanned`,
   `o`.`tstartreal` AS `tstartreal`,
   `o`.`tendreal` AS `tendreal`,
   `o`.`status` AS `status`,
   `o`.`fitspath` AS `fitspath`,
   `o`.`l` AS `l`,
   `o`.`b` AS `b`,
   `o`.`timereftypeid` AS `timereftypeid`,
   `o`.`skyreftypeid` AS `skyreftypeid`,
   `o`.`name` AS `name`,
   `om`.`observingmodeid` AS `observingmodeid`,
   `om`.`instrumentid` AS `instrumentid`,
   `om`.`zenithangle` AS `zenithangle`,
   `om`.`minskyquality` AS `minskyquality`,
   `om`.`minnsb` AS `minnsb`,
   `om`.`maxnsb` AS `maxnsb`,
   `i`.`name` AS `instrumentname`,
   `i`.`irf` AS `irf`,
   `i`.`caldb` AS `caldb`,
   `i`.`fov` AS `fov`,
   `t`.`emin` AS `emin`,
   `t`.`emax` AS `emax`,
   `t`.`targetid` AS `targetid`,
   `t`.`xmlmodel` AS `targetxmlmodel`,
   `skrt`.`name` AS `skyrefname`,
   `trt`.`unit` AS `timerefunit`,
   `skrt`.`unit` AS `skyrefunit`,
   `trt`.`name` AS `timerefname`
FROM ((((((`observation` `o` join `observation_target` `ot` on((`o`.`observationid` = `ot`.`observationid`))) join `target` `t` on((`t`.`targetid` = `ot`.`targetid`))) join `observingmode` `om` on((`om`.`observingmodeid` = `t`.`observingmodeid`))) join `instrument` `i` on((`i`.`instrumentid` = `om`.`instrumentid`))) join `timereftype` `trt` on((`trt`.`timereftypeid` = `o`.`timereftypeid`))) join `skyreftype` `skrt` on((`skrt`.`skyreftypeid` = `o`.`skyreftypeid`)));


# Replace placeholder table for run_to_cancel with correct view syntax
# ------------------------------------------------------------

DROP TABLE `run_to_cancel`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`188.15.168.50` SQL SECURITY DEFINER VIEW `run_to_cancel`
AS SELECT
   `r`.`runid` AS `runid`,
   `r`.`status` AS `status`,
   `r`.`postanalysisid` AS `postanalysisid`,
   `r`.`analysissessionid` AS `analysissessionid`,
   `r`.`jobidscheduler` AS `jobidscheduler`,
   `r`.`tstart` AS `tstart`,
   `r`.`tstop` AS `tstop`
FROM `run` `r` where (`r`.`status` = -(7));


# Replace placeholder table for run_running with correct view syntax
# ------------------------------------------------------------

DROP TABLE `run_running`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`188.15.168.50` SQL SECURITY DEFINER VIEW `run_running`
AS SELECT
   `r`.`runid` AS `runid`,
   `r`.`status` AS `status`,
   `r`.`postanalysisid` AS `postanalysisid`,
   `r`.`analysissessionid` AS `analysissessionid`,
   `r`.`jobidscheduler` AS `jobidscheduler`,
   `r`.`tstart` AS `tstart`,
   `r`.`tstop` AS `tstop`,
   `r`.`l` AS `r_l`,
   `r`.`b` AS `r_b`
FROM `run` `r` where (`r`.`status` = 4);


# Replace placeholder table for run_runnable_noticetrigger with correct view syntax
# ------------------------------------------------------------

DROP TABLE `run_runnable_noticetrigger`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `run_runnable_noticetrigger`
AS SELECT
   `ant`.`shortname` AS `ant_sname`,
   `anst`.`shortname` AS `anst_sname`,
   `anstno`.`observationid` AS `observationid`,
   `r`.`runid` AS `runid`,
   `r`.`tstart` AS `tstart`,
   `r`.`tstop` AS `tstop`,
   `r`.`l` AS `l`,
   `r`.`b` AS `b`,
   `r`.`r` AS `radius`,
   `r`.`diroutputrun` AS `diroutputrun`,
   `ans`.`diroutputresults` AS `diroutputresults`,
   `ant`.`deleterun` AS `deleterun`,
   `anst`.`reservation` AS `reservation`,
   `anst`.`queue` AS `queue`,
   `anst`.`submit_priority` AS `submit_priority`,
   `ant`.`metaconffile` AS `metaconffile`,
   `ant`.`task` AS `task`,
   `dpt`.`module` AS `module`,
   `eb`.`emin` AS `emin`,
   `eb`.`emax` AS `emax`,
   `anst`.`skypositiontype` AS `skypositiontype`,
   `skrt`.`name` AS `skyrefname`,
   `skrt`.`unit` AS `skyrefunit`,
   `trt`.`name` AS `timerefname`,
   `trt`.`unit` AS `timerefunit`,
   `n`.`contour` AS `contour`,
   `n`.`notice` AS `notice_xml`,
   `n`.`url` AS `ligo_map_url`,
   `n`.`type` AS `notice_type`,
   `n`.`seqnum` AS `seqnum`,
   `n`.`error` AS `n_radius`,
   `ta`.`xmlmodel` AS `targetxml`,
   `ta`.`targetid` AS `targetid`,
   `obs`.`l` AS `obs_l`,
   `obs`.`b` AS `obs_b`,
   `anst`.`analysisradius` AS `analysisradius`,
   `inst`.`fov` AS `fov`,
   `alert_inst`.`name` AS `alert_instr_name`,
   `rsa`.`time` AS `tzero`,
   `rsa`.`triggerid` AS `triggerid`
FROM (((((((((((((((((`run` `r` join `analysissession` `ans` on((`ans`.`analysissessionid` = `r`.`analysissessionid`))) join `analysissessiontype_notice_observation` `anstno` on((`anstno`.`analysissessiontype_notice_observationid` = `ans`.`analysissessiontype_notice_observationid`))) join `analysissessiontype_notice` `anstn` on((`anstn`.`analysissessiontype_noticeid` = `anstno`.`analysissessiontype_noticeid`))) join `analysissessiontype` `anst` on((`anst`.`analysissessiontypeid` = `anstn`.`analysissessiontypeid`))) join `analysistype` `ant` on((`ant`.`analysistypeid` = `anst`.`analysistypeid`))) join `dataprocessingtool` `dpt` on((`dpt`.`dataprocessingtoolid` = `ant`.`dataprocessingtoolid`))) join `energybin` `eb` on((`eb`.`energybinid` = `r`.`energybinid`))) join `skyreftype` `skrt` on((`skrt`.`skyreftypeid` = `dpt`.`skyreftypeid`))) join `timereftype` `trt` on((`trt`.`timereftypeid` = `dpt`.`timereftypeid`))) join `notice` `n` on((`n`.`noticeid` = `anstn`.`noticeid`))) join `receivedsciencealert` `rsa` on((`rsa`.`receivedsciencealertid` = `n`.`receivedsciencealertid`))) join `observation_target` `ota` on((`ota`.`observationid` = `anstno`.`observationid`))) join `target` `ta` on((`ta`.`targetid` = `ota`.`targetid`))) join `observation` `obs` on((`obs`.`observationid` = `anstno`.`observationid`))) join `observingmode` `obsm` on((`obsm`.`observingmodeid` = `ta`.`observingmodeid`))) join `instrument` `inst` on((`inst`.`instrumentid` = `obsm`.`instrumentid`))) join `instrument` `alert_inst` on((`alert_inst`.`instrumentid` = `rsa`.`instrumentid`))) where ((`r`.`status` = 2) and isnull(`r`.`postanalysisid`));

/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
