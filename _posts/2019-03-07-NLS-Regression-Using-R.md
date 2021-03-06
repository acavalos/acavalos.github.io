---
published: true
---
Back in December, I was involved in an auto accident that left my 2016 Chevrolet Sonic totaled. After 
the other party was found at fault, I was paid out. I figured, hey, this is the perfect time 
for another blog post! Today, we will be doing some Non-Linear Regression in R.

Similar to my last post, I've web-scraped car listings on Craigslist. Instead of looking 
at age vs price, we are going to investigate odometer vs price. We will review the most popular sedans 
and see which vehicle has a decent initial cost, coupled with a slow decay rate in value. 

### Shaping The Data

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
auto[,c('make','model','type')] <- car_models[closest,c('brand','models','types')]
```

Now, I'm no millionaire, so I do have a budget to consider. At the same time, I'm not 
looking to buy a vehicle with mileage higher than 100k. For this reason, I will remove 
postings outside of my interests.

```R
auto$price = as.numeric(gsub("[^0-9\\.]", "", auto$price)) 
auto <- auto[!(is.null(auto$odometer)) & !(is.na(auto$odometer)),]
auto <- auto[!(is.null(auto$price)) & !(is.na(auto$price)),]
auto <- auto[auto$odometer<100000,]
auto <- auto[auto$price<50000,]
auto <- auto[auto$title_status == "clean",]

plot(auto$odometer,auto$price)
```
<p align = "center">
	<img src ="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/auto/initial2.png" width="600" />
</p>

We will fit the following model:

<p align="center">
$$
price_i = e^{a+b*odo_i} + \sigma_i \\
\sigma_i \approx error
$$
</p>

We'll see the most popular models and keep the top sedans. Moreover, we will change the units 
such that 1 = $1000, and 1 = 1000 miles.

```R
auto$full_title <- mapply(function(x,y) paste(x,y),auto$make,auto$model)
sort(table(auto$full_title))


keep = c("honda civic","honda accord","toyota camry","nissan altima",
        "ford focus","ford fusion","chevrolet impala","toyota corolla",
        "hyundai sonata","chevrolet cruze","hyundai elantra","toyota prius",
        "nissan sentra","volkswagen jetta","subaru impreza",
        "ford fiesta","nissan maxima")

auto <- auto[auto$full_title %in% keep,]
auto$price = auto$price/1000
auto$odometer = auto$odometer/1000
```

Perfect, we have all the data we want. The next part is creating the models.
Since we are working with Non-Linear Regression, we need to use the nls() 
function. Unfortunately, to achieve the end goal of providing prediction and confidence intervals, 
we need to create them ourselves! For whatever reason, nls() does not return these intervals. To 
make these intervals, we need to review the theory and build them manually. In fake code, the nls() function will work as follows:

```R
#NLS takes starting parameter *vector* B_0 
#and either converges or diverges onto the best model
#given general function f(x|B)
fit = nls(formula = y ~ f(x|B), start = list(B = B_0))
```

In basic calculus, we learned the derivative. The derivative indicates the SLOPE of the best fit LINE to the curve. 
Here, we will be doing something equivalent. If we theorize the data to adhere to some 
non-linear function, we can linearize the model at each observation! 

Our Model:
<p align="center">
$$
y_i = f(x_i|\beta) + e_i
$$    
</p>

Given our model $$f$$ with estimated parameters $$\hat{\beta}$$, we can use the Delta-Method for prediction
and confidence.

From calculus, we have that we can linearize $$f$$, as a function of $$\beta$$ at any observation $$x_0$$
<p align="center">
$$
f(x_0,\beta) \simeq f(x_0|\hat{\beta}) + \nabla f(x_0,\hat{\beta})(\beta - \hat{\beta})
$$    
</p>

Then we can approximate $$Var(f(x_0,\hat{\beta}))$$:
<p align="center">
$$
\begin{align*}
Var(f(x_0,\beta)) &\simeq Var(f(x_0|\hat{\beta}) + \nabla f(x_0,\hat{\beta})(\beta - \hat{\beta}))\\
		&= Var(f(x_0|\hat{\beta}) + \nabla f(x_0|\hat{\beta})^T \cdot \beta - \nabla f(x_0|\hat{\beta})^T \cdot \hat{\beta})\\
		&= Var(\nabla f(x_0|\hat{\beta})^T \cdot \beta)\\
		&= \nabla f(x_0|\hat{\beta})^T \cdot Cov(\beta) \cdot \nabla f(x_0|\hat{\beta})
\end{align*}
$$
</p>

Awesome, with this we are close to creating our confidence and prediction bands.
Our 95% CI and PI becomes 

<p align="center">
$$
CI_{lin,1-\alpha}(f(x_0|\beta)) = [f(x_0|\hat{\beta}) + qt_{\frac{\alpha}{2}, df=n-d} s.e.(f(x_0|\hat{\beta})),f(x_0|\hat{\beta}) + qt_{1 - \frac{\alpha}{2}, df=n-d} s.e.(f(x_0|\hat{\beta}))]
$$
</p>
where $$s.e.(f(x_0|\hat{\beta})) = \sqrt{\nabla f(x_0|\hat{\beta})^T \cdot Cov(\beta) \cdot \nabla f(x_0|\hat{\beta})}$$,



<p align="center">
$$
PI_{lin,1-\alpha}(f(x_0|\beta)) = [f(x_0|\hat{\beta}) + qt_{\frac{\alpha}{2}, df=n-d} s.e.(\hat{y_0}),f(x_0|\hat{\beta}) + qt_{1 - \frac{\alpha}{2}, df=n-d} s.e.(\hat{y_0})]
$$
</p>
where $$s.e.(\hat{y_0}) = \sqrt{\nabla f(x_0|\hat{\beta})^T \cdot Cov(\beta) \cdot \nabla f(x_0|\hat{\beta}) + \sigma ^ 2}$$ and $$\sigma ^ 2 = Var(\hat{e_i})$$



I will create a function which takes the input and response variables, and returns 
a list object containing the fit and the prediction/confidence intervals using the above theory. 
Moreover, my list will contain the confidence/prediction plots of the data for easy visualization.
I will use the ggplot2 library, since I feel it is a good mix of ease and cleanliness.

```R
library(stats)
library(ggplot2)

create_model <- function(input,resp,name) {
    fit <- nls(resp~exp(a+b*input),start = list(a=log(20),b=-0.001))
    B <- coef(fit)
    n <- length(input)
    d <- 2
    
    
    pred <- function(x) {
        #Generate predictions
        return(exp(B["a"]+B["b"]*x))
    }
    sig.est = sqrt(sum((resp-pred(input))^2)/(n-d))
    
    #Linearize model for confidence and prediction
    #f(x|B) ~ f(x|B_hat) + gradient(f(x|B_hat)*(B - B_hat)
    #y~f(x|B)+e  <=> g = gradient()(a,b)
    #                z = y - g + g*B
    mdiv <- deriv(y~exp(a+b*x),c("a","b"),function(a,b,x){})
    G <- mdiv(a=B["a"],b=B["b"],input)
    G <- attr(G,"gradient")
    z <- resp - pred(input) + G%*%B
    
    #Find linear standard error
    var.lin <- ((sig.est^2)*solve(t(G)%*%G))
    se.lin <- sqrt(diag(var.lin))
    
    #Model parameters of lineraized version can be treated
    #linearly
    
    #Confidence of parameters
    level <- 0.95
    alpha <- 1-level
    B.ci <- cbind(B + qt(alpha/2,n-d)*se.lin, B + qt(1-alpha/2,n-d)*se.lin)
    row.names(B.ci) <- names(B)
    colnames(B.ci) <- c(paste0((1-level)/2*100,"%"),paste0((1+level)/2 * 100,"%"))
    
    #Confidence
    input.new <- seq(0,100,1)
    pred.input.new <- pred(input.new)
    grad2 <- mdiv(a=B["a"],b=B["b"],input.new)
    G2 <- attr(grad2,"gradient")
    GS <- rowSums((G2%*%vcov(fit))*G2)
    delta <- sqrt(GS)*qt(1-alpha/2, n-d)
    df.delta <- data.frame(odometer=input.new,price = pred.input.new,
                            lwr.conf = pred.input.new-delta,upr.conf = pred.input.new+delta)
    
    #Prediction
    sig2.est <- summary(fit)$sigma
    pred.delta <- sqrt(GS + sig2.est^2)*qt(1-alpha/2,n-d)
    df.delta[c("lwr.pred","upr.pred")] <- cbind(pred.input.new - pred.delta,
                                                 pred.input.new + pred.delta)
    input.df <- data.frame(odometer=input,price=resp)
    
    #Create plot
    p = ggplot(data = df.delta,aes(x=odometer,y=price))+geom_point(data=input.df)+
                geom_line(size = 1.5,col="green")+
                geom_ribbon(aes(ymin = lwr.conf,ymax = upr.conf,color="95% Confidence"),alpha = 0.2,fill = "green")+
                geom_ribbon(aes(ymin = lwr.pred,ymax = upr.pred,color="95% Prediction"),alpha = 0.2,fill = "blue") +
                scale_colour_manual(name="",values=c("95% Confidence"="green","95% Prediction"="blue"))+
                labs(title = paste(name, "prediction plot"))
    
    return(list(fit = fit,B.conf = B.ci, pred = df.delta,df = input.df,plot = p))
}
```

I opt to use a for-loop since the apply functions aren't necessary and less readable.

```R 
model_list <- list()
for(name in unique(auto$full_title)){
    df.temp <- auto[auto$full_title == name,]
    model_list[[name]] <- create_model(df.temp$odometer,
    					df.temp$price,name)
    rm(df.temp)
}

#DataFrame for parameters for ease 
param.df <- data.frame(full_title = unique(auto$full_title))
param.df$a.lwr = sapply(model_list, function(x) t(x$B.conf["a",1]))
param.df$a.upr = sapply(model_list, function(x) t(x$B.conf["a",2]))
param.df$b.lwr = sapply(model_list, function(x) t(x$B.conf["b",1]))
param.df$b.upr = sapply(model_list, function(x) t(x$B.conf["b",2]))
```

### Dealing With The Outliers

Sifting through our model plots, it's easy to see there are certain samples that are affecting our 
model fits. This can be validated by reviewing the Cook's distance of the samples. For our purposes, we 
are going to be controversial and remove any sample outside our confidence intervals. We then will re-run our 
model fitting with the cleaned data. Normally outlier removal must be done with caution, but because these outliers 
are so significant and numerous, it is justified in this case. 

<p align = "center">
	<img src ="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/auto/outlier2.png" alt="Example" width="600" height="337.5"/>
</p>

```R 
auto.clean = merge(auto,param.df,by="full_title")
logic.lwr = auto.clean$price > exp(auto.clean$a.lwr+auto.clean$b.lwr*auto.clean$odometer)
logic.upr = auto.clean$price < exp(auto.clean$a.upr+auto.clean$b.upr*auto.clean$odometer)
auto.clean = auto.clean[logic.lwr & logic.upr,]

model_list <- list()
for(name in unique(auto.clean$full_title)){
    df.temp <- auto.clean[auto.clean$full_title == name,]
    model_list[[name]] <- create_model(df.temp$odometer,df.temp$price,name)
    rm(df.temp)
}

param.df <- data.frame(full_title = unique(auto.clean$full_title))
param.df$a <- sapply(model_list,function(x) summary(x$fit)$coefficients["a",1])
param.df$a.lwr = sapply(model_list, function(x) t(x$B.conf["a",1]))
param.df$a.upr = sapply(model_list, function(x) t(x$B.conf["a",2]))
param.df$b <- sapply(model_list,function(x) summary(x$fit)$coefficients["b",1])
param.df$b.lwr = sapply(model_list, function(x) t(x$B.conf["b",1]))
param.df$b.upr = sapply(model_list, function(x) t(x$B.conf["b",2]))
```

For comparison with the previous image used, here is the new model with the outliers removed:
<p align = "center">
	<img src="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/auto/ford_fiesta2.png" alt="cleaned" width="600" height = "337.5"/>
</p>


The rest of the plots can be found [here](https://github.com/acavalos/acavalos.github.io/tree/master/images/auto)

### Finding Best Value Vehicle

The most important feature according to our model is the decay rate. We want to find the best vehicle within our means 
that will hold consistent value. What is the point of buying a cheap vehicle if it degrades quickly? Using some simple 
algebra, we see the percetage of degradation $$D(x) = \frac{f(0)-f(x)}{f(0)}$$ per x*1k miles as:

<p align = "center">
$$
\begin{align*}
D(x) &= \frac{e^a - e^{a+b \cdot x}}{e^a}\\
	 &= \frac{e^a - e^{a} \cdot e^{b \cdot x}}{e^a}\\
	 &= \frac{e^a \cdot (1 - e^{b \cdot x})}{e^a}\\
	 &= 1 - e^{b \cdot x}
\end{align*}
$$
</p>

```R
loss <- function(decay) {
	return(1 - exp(decay*seq(0,100,1)))
}
decay.df = data.frame(full_title = as.character(),odometer = as.numeric(),price = as.numeric())
for(name in param.df$full_title){
	x = seq(0,100,1)
	temp.df = data.frame(full_title = rep(name,length(x)),
							odometer=x,
							price = loss(param.df[param.df$full_title==name,]$b))
	decay.df <- rbind(decay.df,temp.df)
	rm(temp.df)
}
```

<p align = "center">
	<img src="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/auto/decay2.png" alt="Ranked Decay" width="600" />
</p>

To summarize the information, we can plot the confidence bands of each models inital cost and decay rate. I will sort by the 
initial cost to make it easier for the eye test.

```R
#Force ggplot to order correctly
param.df$full_title <- factor(param.df$full_title, 
                                levels = param.df$full_title[rev(order(param.df$a))])

p1 <- ggplot(param.df, aes(y=exp(a),x=full_title)) + 
                geom_errorbar(aes(ymin=exp(a.lwr),ymax=exp(a.upr))) + 
                geom_point() + ylab("Initial Cost") + xlab("Full Title") + coord_flip()

p2 <- ggplot(param.df, aes(y=b,x=full_title)) + 
                geom_errorbar(aes(ymin=b.lwr,ymax=b.upr)) + 
                geom_point() + ylab("Decay Rate") + xlab(NULL) + coord_flip()
grid.arrange(p1,p2,nrow=1)
```
<p align = "center">
	<img src="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/auto/bands.png" alt="Ranked Initial Cost" width="800" />
</p>

As most would expect, Toyota leads the pack in value. Even more impressive is how much more 
a value the Camry and Corrolla have over the Honda Civic and Accord. Steer clear of the Chevy Impala though! 
This all just reaffirms what we all know, Toyota makes consumer friendly vehicles.

### Conclusions

Before starting this short project, I honestly didnt know very much about the various car brands and 
their reputations. It's really powerful that we can utilize some basic concepts and become more informed. To 
reiterate, we retrieved lots of data from Craigslist. We cleaned the data of most the junk, then did some simple 
regression in order to be able to predict the price range we expect when buying a used car.


From here, we can find the sedan we would like and check if its asking price is above or below what our model predicts 
it to be worth. We can then proceed to find any reasons as to why it appears to be a good deal. 
