---
published: true
---

Back in December, I was involved in an auto accident that left my Chevy Sonic totaled. After 
the other party was found at fault, I was paid out. I figured, hey, this is the perfect time 
for another blog post! Today, we will be doing some Non-Linear Regression.

Just like my last post, I've web-scraped car listings on Craigslist. Instead of looking 
at age vs price, we are going to investigate odometer vs price. We will popular sedan models 
and see which vehicle has a low initial cost, and a slow decay rate in value. 

# Shaping The Data

```R
library(sqldf)
db = dbConnect(SQLite(),"auto_posts.sql")
auto = dbGetQuery(db, "SELECT car,odometer,price,title_status FROM auto")
dbDisconnect(db)
```

We need to introduce a categorical variable in the car model. We will read in an extensive list 
of makes and models and string match the craigslist posts.

```R
car_models <- read.csv(file='car_models.csv',header=TRUE,strip.white = TRUE)
car_models$full_title <- trimws(paste(car_models$brand,car_models$models,car_models$types))
for(column in colnames(car_models)){
    car_models[,column] <- tolower(car_models[,column])
}

closest_model <- function(car_model){
    id = agrep(car_model,car_models$Full)
    return(car_models$Full[id])
}
auto$car <- tolower(auto$car)

#create matrix of string distances
string_dist <- adist(auto$car,car_models$Full)
rownames(string_dist) <- row.names(auto)
colnames(string_dist) <- row.names(car_models)

closest <- apply(string_dist,1,which.min)

auto[,'make'] <- NA
auto[,'model'] <- NA
auto[,'type'] <- NA

auto[,c('make','model','type')] <- car_models[closest,c('brand','models','types')]
```

Now, I'm no millionaire, so I do have a budget to consider. At the same time, I'm not 
looking to buy a vehicle with mileage higher than 100k. For this reason, I will remove 
postings outside of my interests.

```R
auto$price = as.numeric(gsub("[^0-9\\.]", "", auto$price)) 
auto <- auto[auto$odometer<100000,]
auto <- auto[auto$price<50000,]
auto <- auto[!(is.null(auto$odometer)) & !(is.na(auto$odometer)),]
auto <- auto[!(is.null(auto$price)) & !(is.na(auto$price)),]
auto <- auto[auto$title_status == "clean",]

plot(auto$odometer,auto$price)
```

There is a clear indication of an inverse relationship. We will fit the following model:

<p align="center">
$$
\price_i = e^(a+b*odo_i) + \sigma_i
$$    
</p>
