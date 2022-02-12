-- MySQL dump 10.13  Distrib 5.6.51, for Linux (x86_64)
--
-- Host: localhost    Database: lamp
-- ------------------------------------------------------
-- Server version	5.6.51

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `data`
--

DROP TABLE IF EXISTS `data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` varchar(1000) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `data`
--

LOCK TABLES `data` WRITE;
/*!40000 ALTER TABLE `data` DISABLE KEYS */;
INSERT INTO `data` VALUES (1,'Hello, cloud architect!');
INSERT INTO `data` VALUES (2,'This is a message retrieved from MySQL.');
INSERT INTO `data` VALUES (3,'PHP is querying the `data` table from the `lamp` db.');
INSERT INTO `data` VALUES (4,'Each number in brackets is the `id` field, the unique primary key.');
INSERT INTO `data` VALUES (5,'Each associated message is text from the `message` field.');
INSERT INTO `data` VALUES (6,'┌──────────────┐');
INSERT INTO `data` VALUES (7,'│ mysql server │');
INSERT INTO `data` VALUES (8,'│              │ (backend)');
INSERT INTO `data` VALUES (9,'│   port 3306  │');
INSERT INTO `data` VALUES (10,'└───────▲──────┘');
INSERT INTO `data` VALUES (11,'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│');
INSERT INTO `data` VALUES (12,'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│');
INSERT INTO `data` VALUES (13,'┌───────┴───────┐');
INSERT INTO `data` VALUES (14,'│ apache server │ (frontend)');
INSERT INTO `data` VALUES (15,'│ ┌───────────┐ │');
INSERT INTO `data` VALUES (16,'│ │&nbsp; port 80 &nbsp;│ │ (container port)');
INSERT INTO `data` VALUES (17,'└─┼───────────┼─┘');
INSERT INTO `data` VALUES (18,'&nbsp;&nbsp;│ port 8000 │   (host port)');
INSERT INTO `data` VALUES (19,'&nbsp;&nbsp;└─────▲─────┘');
INSERT INTO `data` VALUES (20,'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│');
INSERT INTO `data` VALUES (21,'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;│');
INSERT INTO `data` VALUES (22,' ┌──────┴──────┐');
INSERT INTO `data` VALUES (23,' │ web browser │');
INSERT INTO `data` VALUES (24,' └─────────────┘');

/*!40000 ALTER TABLE `data` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2022-02-12 18:19:15
