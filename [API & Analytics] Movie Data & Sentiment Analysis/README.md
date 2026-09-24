# Movie Data & Sentiment Analysis

## 📌 Project Overview

This project collects movie data through the **TMDB API** and combines structured movie information with text-based sentiment analysis.

The objective is to explore both quantitative movie characteristics and textual information contained in movie overviews.

---

## 🎯 Analysis Objectives

This project focuses on:

1. How movie data can be collected automatically through an API
2. What patterns can be observed in movie popularity and ratings
3. How movie overview text can be processed for text analytics
4. What sentiment patterns appear across movie descriptions
5. How structured and unstructured data can be analyzed together

---

## 🛠️ Tools Used

- Python
- Requests
- TMDB API
- Pandas
- NumPy
- NLP
- Sentiment Analysis
- Matplotlib
- Jupyter Notebook

---

## 🔍 Analysis Process

### 1. API Data Collection

Retrieved movie information from the **TMDB API** using Python requests.

### 2. Data Preparation

Processed movie-related variables including:

- Movie title
- Release information
- Popularity
- Ratings
- Vote count
- Movie overview

### 3. Exploratory Data Analysis

Explored the distribution and relationships of structured movie variables.

### 4. Text Preprocessing

Prepared movie overview text for sentiment analysis.

### 5. Sentiment Analysis

Analyzed the sentiment characteristics of movie overview text and compared sentiment patterns across the dataset.

---

## 💡 Key Insights

- API-based data collection provides an efficient and reproducible method for building movie datasets.
- Movie data combines both structured attributes and unstructured text, enabling multiple types of analysis.
- Sentiment analysis provides an additional perspective on movie overview content beyond numerical ratings.
- Text-based sentiment should be interpreted as a characteristic of the overview text rather than direct audience sentiment.

---

## 💼 Analytical Value

This project demonstrates an end-to-end workflow combining:

**API Data Collection → Data Cleaning → Exploratory Analysis → NLP → Sentiment Analysis**

It also illustrates how structured and unstructured data can be integrated within a single analytics project.

---

## 📂 Repository Structure

```text
.
├── README.md
├── movie_sentiment_analysis.ipynb
├── dataset/
├── images/
└── presentation/
