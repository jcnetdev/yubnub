CREATE TABLE `banned_url_patterns` (
  `id` int(11) NOT NULL auto_increment,
  `pattern` varchar(255) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `commands` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `url` text,
  `description` text,
  `uses` bigint(11) default '0',
  `spam` tinyint(1) default '0',
  `last_use_date` datetime default NULL,
  `golden_egg_date` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('0');