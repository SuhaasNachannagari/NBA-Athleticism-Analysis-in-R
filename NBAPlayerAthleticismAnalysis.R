# INstalling python package to help us bring over the dataset using kaggle api key

system("pip install kaggle")
system("kaggle datasets download wyattowalsh/basketball -p data/")
unzip("data/basketball.zip", exdir = "data/")
list.files("data/")
combine_stats <- read.csv("data/csv/draft_combine_stats.csv")

# Examining the dataframe
head(combine_stats)

# Importing package to help us summarize the data within the dataframe as well as visualize them
install.packages("dplyr")
library(dplyr)
install.packages("ggplot2")
library(ggplot2)

# Selecting variables
select_stats <- select(combine_stats, wingspan, max_vertical_leap, lane_agility_time, 
                        position, season, standing_reach, bench_press)

# Aggregating all combination positions like PG-SG into the 5 basic positions based on which comes first
select_stats$position <- sub("-.*", "", select_stats$position)

#Visualizing the columns by position, histograms and barplots:
numerical_cols <- c("wingspan", "max_vertical_leap", "lane_agility_time", 
                    "standing_reach", "bench_press")

# Histograms of numerical variables :)
for (col in numerical_cols) {
  plot <- ggplot(select_stats, aes(x = .data[[col]])) +
    geom_histogram(binwidth = 1, fill = "blue", color = "black", alpha = 0.7) +
    geom_density(alpha = 0.3, fill = "red") +
    labs(title = paste("Distribution of", col), x = col, y = "Frequency") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))
  print(plot) # Print each plot
}

#Histogram of position counts, how many players are present from each position
ggplot(select_stats, aes(x = position)) +
  geom_bar(fill = "blue", color = "black") +
  labs(title = "Number of Players per Position", x = "Position", y = "Count") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#Line plots with average max vertical leaps each year since 2000
ggplot(select_stats, aes(x = season, y = max_vertical_leap)) +
  stat_summary(fun = "mean", geom = "line", color = "darkblue", size = 1) +
  labs(title = "Average Max Vertical Leap per Year", x = "Season", y = "Average Max Vertical Leap (inches)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#Line plots with average lane agility each year since 2000
ggplot(select_stats, aes(x = season, y = lane_agility_time)) +
  stat_summary(fun = "mean", geom = "line", color = "darkblue", size = 1) +
  labs(title = "Average Lane Agility Time per Year", x = "Season", y = "Lane Agility Time (Sec)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))


#Wingspan by Position boxplot
ggplot(select_stats, aes(x = position, y = wingspan)) +
  geom_boxplot(fill = "lightblue", color = "darkblue", outlier.color = "red") +
  labs(title = "Wingspan by Position", x = "Position", y = "Inches") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#Lane Agility by Position boxplot
ggplot(select_stats, aes(x = position, y = lane_agility_time)) +
  geom_boxplot(fill = "lightblue", color = "darkblue", outlier.color = "red") +
  labs(title = "Lane Agility Time by Position", x = "Position", y = "Seconds") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#Vertical Leap by Position boxplot
ggplot(select_stats, aes(x = position, y = max_vertical_leap)) +
  geom_boxplot(fill = "lightblue", color = "darkblue", outlier.color = "red") +
  labs(title = "Max Vertical Leap by Position", x = "Position", y = "Inches") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#Standing Reach by Position boxplot
ggplot(select_stats, aes(x = position, y = standing_reach)) +
  geom_boxplot(fill = "lightblue", color = "darkblue", outlier.color = "red") +
  labs(title = "Standing Reach by Position", x = "Position", y = "Inches") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

#Bench Press by Position boxplot
ggplot(select_stats, aes(x = position, y = bench_press)) +
  geom_boxplot(fill = "lightblue", color = "darkblue", outlier.color = "red") +
  labs(title = "Bench Press Reps by Position", x = "Position", y = "Reps") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

# Calculate means of each variable for each position, preparation for hypothesis testing based on position.
summarized_data <- summarize(group_by(select_stats, position), 
                             mean_wingspan = mean(wingspan, na.rm = TRUE), 
                             mean_vertical_leap = mean(max_vertical_leap, na.rm = TRUE), 
                             mean_agility_time = mean(lane_agility_time, na.rm = TRUE), 
                             mean_standing_reach = mean(standing_reach, na.rm = TRUE), 
                             mean_bench_press = mean(bench_press, na.rm = TRUE))

# Dataframe for ANOVA testing without na values
max_vertical_anova_df = select_stats[!is.na(select_stats$position) & select_stats$position != "", ]
# Anova testing implementation
anova_result <- aov(max_vertical_leap ~ position, data = max_vertical_anova_df)
summary(anova_result)

# Finding the specific difference using TukeyHSD
tukey_result <- TukeyHSD(anova_result)
tukey_result

# Correlation analysis dataset 
reach_stats <- select(select_stats, wingspan, standing_reach)

# Remove rows with NA values for wingspan and standing reach
reach_stats <- na.omit(reach_stats)

# Correlation analysis
correlation <- cor.test(reach_stats$wingspan, reach_stats$standing_reach)
correlation


# Simple Linear Regression Model
linear_model <- lm(standing_reach ~ wingspan, data = reach_stats)
summary(linear_model)

# Plot the regression line with data points
ggplot(select_stats, aes(x = wingspan, y = standing_reach)) +
  geom_point(color = "blue", alpha = 0.6) +
  geom_smooth(method = "lm", color = "red", se = TRUE) +
  labs(title = "Relationship between Wingspan and Standing Reach",
       x = "Wingspan (inches)",
       y = "Standing Reach (inches)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

# 2-Sample Independent T-Test between high-low wingspan groups for bench press

# Split data based on the median wingspan
median_wingspan <- median(select_stats$wingspan, na.rm = TRUE)
high_wingspan_group <- select_stats$bench_press[select_stats$wingspan > median_wingspan]
low_wingspan_group <- select_stats$bench_press[select_stats$wingspan <= median_wingspan]

# Perform a two-sample t-test
t_test_result <- t.test(high_wingspan_group, low_wingspan_group)
print(t_test_result)

# Print the confidence interval from the t-test
print(t_test_result$conf.int)

