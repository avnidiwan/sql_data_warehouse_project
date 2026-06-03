# Data Warehouse Project

## Overview

This project is a hands-on implementation of a modern data warehouse using SQL Server. As part of my learning journey in Data Engineering, I built a layered data warehouse architecture to process and integrate data from multiple source systems.

The project follows the Bronze, Silver, and Gold architecture pattern, where raw data is ingested, cleaned, transformed, and organized into business-ready datasets. The goal was to gain practical experience with ETL processes, data quality management, and data warehouse design using real-world datasets.

## Project Objectives

* Understand the fundamentals of Data Warehousing.
* Learn how to design and implement a multi-layered data warehouse.
* Practice ETL concepts using SQL Server and T-SQL.
* Improve SQL skills through data transformation and integration tasks.
* Build a portfolio project demonstrating core Data Engineering concepts.

## Project Features

### Data Ingestion

* Imported CRM and ERP datasets provided as CSV files.
* Loaded raw data into the Bronze layer using SQL Server bulk loading techniques.

### Data Transformation & Quality Management

* Performed data cleansing and standardization in the Silver layer.
* Resolved common data quality issues such as missing values, duplicates, and inconsistent formats.
* Applied transformations to improve data consistency and usability.

### Data Integration

* Combined CRM and ERP data into a unified warehouse structure.
* Created relationships between datasets to support business-oriented analysis.

### Gold Layer Development

* Built Gold-layer tables containing cleaned and integrated business data.
* Organized data into a reporting-ready structure for future analytics and dashboarding purposes.

## Architecture

The project follows a three-layer data warehouse architecture:

### Bronze Layer

Stores raw data imported directly from source systems without modifications.

### Silver Layer

Contains cleansed, validated, and standardized data prepared for integration.

### Gold Layer

Contains business-ready datasets created from transformed and integrated Silver-layer data.

## Technologies Used

* SQL Server
* T-SQL
* CSV Data Sources
* Data Warehousing Concepts
* ETL Processes
* Data Modeling

## Project Scope

This project focuses on data ingestion, transformation, integration, and warehouse modeling up to the Gold layer. Historical data tracking (historization) was not implemented, and the project does not include dashboard creation or advanced analytics.

## Learning Outcomes

Through this project, I gained practical experience with:

* Data warehouse architecture (Bronze, Silver, Gold)
* ETL pipeline development
* Data cleansing and validation
* SQL-based data transformation
* Multi-source data integration
* Data modeling fundamentals
* SQL Server bulk loading techniques
