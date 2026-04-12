/* YOU NEED TO UPDATE LINE 42 IN THIS SQL FILE
Update dynuser, dynhost.mydyndnszone.tld and IP Address to match your setup
You can generate the encrypted password using a tool like htpasswd 
For example: htpasswd -bnB "" yourpassword
*/
--
-- Current Database: `dyndns`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `dyndns` /*!40100 DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci */;

USE `dyndns`;

--
-- Table structure for table `entries`
--

DROP TABLE IF EXISTS `entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `entries` (
  `ID` int(4) NOT NULL AUTO_INCREMENT,
  `USERNAME` varchar(64) NOT NULL,
  `DNS_NAME` varchar(128) NOT NULL,
  `IP_ADDRESS` varchar(16) NOT NULL,
  `FIRSTUPDATE` varchar(32) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `USER_LEVEL` int(11) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `unique_dns_name` (`DNS_NAME`)
) ENGINE=InnoDB AUTO_INCREMENT=10639 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entries`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `entries` WRITE;
/*!40000 ALTER TABLE `entries` DISABLE KEYS */;
INSERT INTO `entries` (ID, USERNAME, DNS_NAME, IP_ADDRESS, FIRSTUPDATE, USER_LEVEL)
VALUES
(1,'dynuser','dynhost.mydyndnszone.tld','127.0.0.2','2011-11-11 13:37:00',1);
/*!40000 ALTER TABLE `entries` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(1,'dynuser','$2y$05$examplehashvaluefor_demo_only','2011-11-11 13:37:00');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
