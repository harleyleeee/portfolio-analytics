# 💬 Restaurant Review Web Scraping & Text Clustering

## 📌 Project Overview

This project collects online restaurant reviews and applies text analytics to identify recurring themes in customer feedback.

The objective is to transform unstructured customer reviews into structured insights that can help businesses better understand customer experiences, preferences, and common discussion topics.

---

## 🎯 Analysis Objectives

This project focuses on the following questions:

1. What are customers frequently discussing in restaurant reviews?
2. Can large volumes of unstructured reviews be grouped into meaningful themes?
3. Which topics appear most frequently across customer feedback?
4. How can review text be transformed into useful customer insights?

---

## 🛠️ Tools Used

- Python
- Pandas
- BeautifulSoup
- Requests
- Scikit-learn
- TF-IDF
- K-Means Clustering
- Matplotlib
- Jupyter Notebook

---

## 🔍 Analysis Process

### 1. Web Scraping

Collected restaurant review information from online sources using Python-based web scraping.

### 2. Data Cleaning

Prepared review text for analysis by:

- Removing unnecessary characters
- Handling missing values
- Standardizing text
- Removing noise from raw review data

### 3. Text Vectorization

Applied **TF-IDF** to convert customer review text into numerical features.

### 4. Text Clustering

Applied **K-Means Clustering** to group reviews with similar textual characteristics.

### 5. Cluster Interpretation

Examined important terms within each cluster to interpret recurring customer themes.

---

## 📊 Key Analysis

### Review Clustering

Customer reviews were grouped into clusters based on textual similarity.

<p align="center">
  <img src="images/cluster_analysis.png" width="800">
</p>

--- 
## 💡 Key Business Insights

- Reviews in Cluster 0 highlight the overall satisfaction with the restaurant
- Reviews in Cluster 1 highlight the good food and service
- Reviews in Cluster 2 highlight specific dishes such as BBQ Korean

## 💼 Business Application

Restaurant businesses can use review text analysis to:

- Monitor recurring customer concerns
- Identify frequently mentioned strengths
- Understand customer expectations
- Supplement traditional rating-based analysis
- Prioritize areas for further customer-experience investigation

---

## 📂 Repository Structure

```text
.
├── README.md
├── restaurant_review_analysis.ipynb
├── dataset/
├── images/
└── presentation/
