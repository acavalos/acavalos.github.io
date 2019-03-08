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
price_i = e^{a+b*odo_i} + \sigma_i
$$    
</p>

We'll see the most popular models and keep the top sedans. Moreover, we will change the units 
such that 1 = $1000, and 1 = 1000 miles.
```R
auto$full_title <- mapply(function(x,y) paste(x,y),auto$make,auto$model)
sort(table(auto$full_title))


keep = c("Honda Civic","Honda Accord","Toyota Camry","Nissan Altima",
        "Ford Focus","Ford Fusion","Chevrolet Impala","Toyota Corolla",
        "Hyundai Sonata","Chevrolet Cruze","Hyundai Elantra","Toyota Prius",
        "Nissan Sentra","Volkswagen Jetta","Subaru Impreza",
        "Ford Fiesta","Nissan Maxima")

auto <- auto[auto$full_title %in% keep,]
auto$price = auto$price/1000
auto$odometer = auto$odometer/1000
```

Perfect, we have all the data we want. The next part is creating the models.
Since we are working with NLS and not Linear Regression, we need to use the nls() 
function. Unfortunately, to achieve the end goal of providing prediction and confidence intervals, 
we need to create them ourselves! For whatever reason, nls() does not return these intervals. To 
make these intervals, we need to understand how nls works. 

In Calc 1, we learned the derivative. The derivate indicates the SLOPE of the best fit LINE to the curve. 
Here, we will be doing something equivalent. If we theorize the data to adhere to some 
non-linear function, we can linearize the model at each observation! At least, that's how I'm 
convinced it works. Regardless, let's get to it.

$$

$$


I will create a function which takes the input and response variables, and returns 
a list object containing the fit and the prediction/confidence intervals.




