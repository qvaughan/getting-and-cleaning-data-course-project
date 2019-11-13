library(data.table)

activity_labels <- read.delim('activity_labels.txt', header=FALSE, sep=' ')
names(activity_labels) <- c('activity_id', 'activity_name')

features <- read.delim('features.txt', header=FALSE, sep=' ')
names(features) <- c('feature_id', 'feature_name')

read_data_set <- function(type) {
  x <- read.fwf(paste(type, '/X_', type, '.txt', sep=''), rep(16, 561), header=FALSE)
  names(x) <- features$feature_name
  y <- read.delim(paste(type, '/y_', type, '.txt', sep=''), header=FALSE)
  names(y) <- c('activity_id')
  subjects <- read.delim(paste(type, '/subject_', type, '.txt', sep=''), head=FALSE, col.names=c('subject_id'))
  x <- cbind(x, subjects)
  x <- cbind(x, merge(y, activity_labels, by='activity_id')[, 2])
  names(x)[563] <- 'activity_name'
  x
}

train <- read_data_set('train')
test <- read_data_set('test')
data_set <- rbind(train, test)
columns <- grep('.*-(std|mean)\\(\\)-[XYZ].*|subject_id|activity_name', names(data_set))
data_set <- data_set[, columns]
names(data_set) <- gsub('\\(\\)', '', names(data_set))
names(data_set) <- gsub('-', '_', names(data_set))
data_set_mean <- data.table(data_set)[,lapply(.SD, mean), by='activity_name,subject_id', .SDcols=1:47]
write.table(data_set_mean, file='data_set_mean.txt', col.names=FALSE)
