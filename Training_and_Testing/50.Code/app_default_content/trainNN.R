library(neuralnet)
library(nnet)

#process arguments passed into the script
args <- commandArgs(trailingOnly = TRUE)

print("===processing input parameters====")

if(length(args) != 6){
  print("[Error] Invalid Input Parameters")
  quit()
}

print("=========crime type / column to model=============")
print(args[1])
crimeCol = args[1]

print("=== input training data===")
print(args[2])
trainingDataCsv = args[2]

print("===directory to output model=======")
print(args[3])
modelDir = args[3]

print("======Index of Bagged Samples=====")
print(args[4])
indexOfBaggedSamples = as.integer(args[4])

print("===number of hidden nodes=======")
print(args[5])
nHidden = as.integer(args[5])

print("======number of iterations=====")
print(args[6])
nIter = as.integer(args[6])


#load training data
print("loading training data...")
csvData = data.frame(read.csv(trainingDataCsv))
print("Done.")

#Prepare model formula

excluded_predictors_default=c("crime_count", "placeholder_1", "placeholder_2", "census_tra", "year", "hournumber", "dt", "shooting_count", "robbery_count", "assault_count", "hourstart", "wind_speed", "drybulb_fahrenheit", "hourly_precip", "relative_humidity", "dod1_drybulb_fahrenheit", "dod2_drybulb_fahrenheit", "dod3_drybulb_fahrenheit", "wow1_drybulb_fahrenheit", "wow2_drybulb_fahrenheit", "precip_hour_cnt_in_last_1_day", "precip_hour_cnt_in_last_3_day", "precip_hour_cnt_in_last_1_week", "hour_count_since_precip", "month_of_year", "day_of_week")
excluded_predictors_weather=c("fz","ra","ts","br","sn","hz","dz","pl","fg","sa","up","fu","sq","gs","temp_<_neg20","temp_neg20_to_neg11","temp_neg10_to_neg1","temp_0_to_9","temp_10_to_19","temp_20_to_29","temp_30_to_39","temp_40_to_49","temp_50_to_59","temp_60_to_69","temp_70_to_79","temp_80_to_89","temp_90_to_99","temp_100_to_109","temp_110_to_119","temp_>=_120","wind_<_5mph","wind_5_to_10mph","wind_11_to_15mph","wind_16_to_20mph","wind_21_to_25mph","wind_26_to_30mph","wind_31_to_35mph","wind_36_to_40mph","wind_41_to_45mph","wind_46_to_50mph","wind_>=_50mph","rain_=0","rain_0_to_.01","rain_.01_to_.02","rain_.02_to_.03","rain_.03_to_.04","rain_.04_to_.05","rain_.05_to_0.1","rain_0.1_to_0.2","rain_0.2_to_0.3","rain_0.3_to_0.4","rain_0.4_to_0.5","rain_0.5_to_1","rain_>1","humidity_<10","humidity_10_to_20","humidity_20_to_30","humidity_30_to_40","humidity_40_to_50","humidity_50_to_60","humidity_60_to_70","humidity_70_to_80","humidity_80_to_90","humidity_90_to_100","wow_1_change_=0","wow_1_change_1_to_5","wow_1_change_5_to_10","wow_1_change_10_to_20","wow_1_change_20_to_30","wow_1_change_30_to_40","wow_1_change_40_to_50","wow_1_change_>50","wow_1_change_neg1_to_neg5","wow_1_change_neg5_to_neg10","wow_1_change_neg10_to_neg20","wow_1_change_neg20_to_neg30","wow_1_change_neg30_to_neg40","wow_1_change_neg40_to_neg50","wow_1_change_>neg50","wow_2_change_=0","wow_2_change_1_to_5","wow_2_change_5_to_10","wow_2_change_10_to_20","wow_2_change_20_to_30","wow_2_change_30_to_40","wow_2_change_40_to_50","wow_2_change_>50","wow_2_change_neg1_to_neg5","wow_2_change_neg5_to_neg10","wow_2_change_neg10_to_neg20","wow_2_change_neg20_to_neg30","wow_2_change_neg30_to_neg40","wow_2_change_neg40_to_neg50","wow_2_change_>neg50","dod_1_change_=0","dod_1_change_1_to_5","dod_1_change_5_to_10","dod_1_change_10_to_20","dod_1_change_20_to_30","dod_1_change_30_to_40","dod_1_change_40_to_50","dod_1_change_>50","dod_1_change_neg1_to_neg5","dod_1_change_neg5_to_neg10","dod_1_change_neg10_to_neg20","dod_1_change_neg20_to_neg30","dod_1_change_neg30_to_neg40","dod_1_change_neg40_to_neg50","dod_1_change_>neg50","dod_2_change_=0","dod_2_change_1_to_5","dod_2_change_5_to_10","dod_2_change_10_to_20","dod_2_change_20_to_30","dod_2_change_30_to_40","dod_2_change_40_to_50","dod_2_change_>50","dod_2_change_neg1_to_neg5","dod_2_change_neg5_to_neg10","dod_2_change_neg10_to_neg20","dod_2_change_neg20_to_neg30","dod_2_change_neg30_to_neg40","dod_2_change_neg40_to_neg50","dod_2_change_>neg50","dod_3_change_=0","dod_3_change_1_to_5","dod_3_change_5_to_10","dod_3_change_10_to_20","dod_3_change_20_to_30","dod_3_change_30_to_40","dod_3_change_40_to_50","dod_3_change_>50","dod_3_change_neg1_to_neg5","dod_3_change_neg5_to_neg10","dod_3_change_neg10_to_neg20","dod_3_change_neg20_to_neg30","dod_3_change_neg30_to_neg40","dod_3_change_neg40_to_neg50","dod_3_change_>neg50","rain_1d_count_=0","rain_1d_count_1_to_5","rain_1d_count_5_to_10","rain_1d_count_10_to_20","rain_1d_count_20_to_24","rain_2day_count_=0","rain_2day_count_1_to_5","rain_2day_count_5_to_10","rain_2day_count_10_to_20","rain_2day_count_20_to_24","rain_2day_count_24_to_30","rain_2day_count_30_to_36","rain_2day_count_37_to_47","rain_2day_count_48_to_57","rain_2day_count_58_to_65","rain_2day_count_66_to_72","rain_1week_count_=0","rain_1week_count_1_to_5","rain_1week_count_5_to_10","rain_1week_count_10_to_20","rain_1week_count_20_to_24","rain_1week_count_24_to_30","rain_1week_count_30_to_36","rain_1week_count_37_to_47","rain_1week_count_48_to_57","rain_1week_count_58_to_65","rain_1week_count_66_to_72","rain_1week_count_73_to_96","rain_1week_count_97_to_120","rain_1week_count_121_to_144","rain_1week_count_145_to_168","since_rain_count_=0","since_rain_count_1_to_5","since_rain_count_5_to_10","since_rain_count_10_to_20","since_rain_count_20_to_24","since_rain_count_24_to_30","since_rain_count_30_to_36","since_rain_count_37_to_47","since_rain_count_48_to_57","since_rain_count_58_to_65","since_rain_count_66_to_72","since_rain_count_73_to_96","since_rain_count_97_to_120","since_rain_count_121_to_144","since_rain_count_145_to_168","since_rain_count_>168","temp_._neg20", "temp_.._120", "wind_._5mph", "wind_.._50mph", "rain_.0", "rain_.1", "humidity_.10", "change_.0", "change_1_to_5", "change_5_to_10", "change_10_to_20", "change_20_to_30", "change_30_to_40", "change_40_to_50", "change_.50", "change_neg1_to_neg5", "change_neg5_to_neg10", "change_neg10_to_neg20", "change_neg20_to_neg30", "change_neg30_to_neg40", "change_neg40_to_neg50", "change_.neg50", "change_.0.1", "change_1_to_5.1", "change_5_to_10.1", "change_10_to_20.1", "change_20_to_30.1", "change_30_to_40.1", "change_40_to_50.1", "change_.50.1", "change_neg1_to_neg5.1", "change_neg5_to_neg10.1", "change_neg10_to_neg20.1", "change_neg20_to_neg30.1", "change_neg30_to_neg40.1", "change_neg40_to_neg50.1", "change_.neg50.1", "change_.0.2", "change_1_to_5.2", "change_5_to_10.2", "change_10_to_20.2", "change_20_to_30.2", "change_30_to_40.2", "change_40_to_50.2", "change_.50.2", "change_neg1_to_neg5.2", "change_neg5_to_neg10.2", "change_neg10_to_neg20.2", "change_neg20_to_neg30.2", "change_neg30_to_neg40.2", "change_neg40_to_neg50.2", "change_.neg50.2", "change_.0.3", "change_1_to_5.3", "change_5_to_10.3", "change_10_to_20.3", "change_20_to_30.3", "change_30_to_40.3", "change_40_to_50.3", "change_.50.3", "change_neg1_to_neg5.3", "change_neg5_to_neg10.3", "change_neg10_to_neg20.3", "change_neg20_to_neg30.3","change_neg30_to_neg40.3", "change_neg40_to_neg50.3", "change_.neg50.3", "change_.0.4", "change_1_to_5.4", "change_5_to_10.4", "change_10_to_20.4", "change_20_to_30.4", "change_30_to_40.4", "change_40_to_50.4", "change_.50.4", "change_neg1_to_neg5.4", "change_neg5_to_neg10.4", "change_neg10_to_neg20.4", "change_neg20_to_neg30.4", "change_neg30_to_neg40.4", "change_neg40_to_neg50.4", "change_.neg50.4", "count_.0", "count_1_to_5", "count_5_to_10", "count_10_to_20", "count_20_to_24", "count_.0.1", "count_1_to_5.1", "count_5_to_10.1", "count_10_to_20.1", "count_20_to_24.1", "count_24_to_30", "count_30_to_36", "count_37_to_47", "count_48_to_57", "count_58_to_65", "count_66_to_72", "count_.0.2", "count_1_to_5.2", "count_5_to_10.2", "count_10_to_20.2", "count_20_to_24.2", "count_24_to_30.1", "count_30_to_36.1", "count_37_to_47.1", "count_48_to_57.1", "count_58_to_65.1", "count_66_to_72.1", "count_73_to_96", "count_97_to_120", "count_121_to_144", "count_145_to_168", "count_.0.3", "count_1_to_5.3", "count_5_to_10.3", "count_10_to_20.3", "count_20_to_24.3", "count_24_to_30.2", "count_30_to_36.2", "count_37_to_47.2", "count_48_to_57.2", "count_58_to_65.2", "count_66_to_72.2", "count_73_to_96.1", "count_97_to_120.1", "count_121_to_144.1", "count_145_to_168.1", "count_.168")


# remove excluded columns (default includes the crime counts, so add that back in


# I don't think I need this part:
# predictors = !names(csvData) %in% c(excluded_predictors_default) | names(csvData) %in% crimeCol
csvCols=names(csvData)
predictors = csvCols[!csvCols %in% c(excluded_predictors_default)]
trainingData <- csvData[c(crimeCol,predictors)]
rm (csvData)

f <- as.formula(paste(crimeCol, '~' , paste(predictors, collapse = '+')))


#The following part of code is used to calculate the weights

#myWeight <- trainingData[crimeCol]
#tau = 0.001151225
#y_bar= mean(myWeight)
#w_1 =  tau / y_bar
#w_0 = (1 - tau) / (1 - y_bar)
#myWeight[myWeight>=1] <- w_1
#myWeight[myWeight==0] <- w_0

#Train NN model
print("Training model....")
print(f)

trainingMatrix=data.matrix(trainingData)		# A matrix seems to be much more efficient memory-wise
rm(trainingData)

gc()

#ir.nn <- nnet(f, data = trainingData, size = nHidden, weights = myWeight, rang = 0.1, MaxNWts = 30000, decay = 5e-4, maxit = nIter)
ir.nn <- nnet(f, data = trainingMatrix, size = nHidden, rang = 0.1, MaxNWts = 180000, decay = 5e-4, maxit = nIter)

gc()
rm(trainingMatrix)
gc()

#Save trained model in model directory
print("Saving model....")
saveRDS(ir.nn, file = paste(modelDir,"/NNmodel_",indexOfBaggedSamples,".rds",sep = ""))

print(paste("Model",indexOfBaggedSamples,"Finished Training."))


