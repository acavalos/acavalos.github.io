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

Our Model:
<p align="center">
$$
y_i = f(x_i|\beta) + e_i
$$    
</p>

Given our model $f$ with estimated parameters $\hat{\beta}$, we can use the Delta-Method for prediction
and confidence.

From Calculus, we have that we can linearize $f$ at any observation $x_0$
<p align="center">
$$
f(x_0,\beta) \simeq f(x_0|\hat{\beta}) + \nabla f(x_0,\hat{\beta})(\beta - \hat{\beta})
$$    
</p>

Then we can approximate $Var(f(x_0,\hat{\beta}))$:
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
CI_{lin,1-\alpha}(f(x_0|\beta)) = [f(x_0|\hat{\beta}) + qt_{\frac{\alpha,2}, df=n-d} s.e.(f(x_0|\hat{\beta})),f(x_0|\hat{\beta}) + qt_{1 - \frac{\alpha,2}, df=n-d} s.e.(f(x_0|\hat{\beta}))]
$$
where $s.e.(f(x_0|\hat{\beta})) = \sqrt{\nabla f(x_0|\hat{\beta})^T \cdot Cov(\beta) \cdot \nabla f(x_0|\hat{\beta})}$,

$$
PI_{lin,1-\alpha}(f(x_0|\beta)) = [f(x_0|\hat{\beta}) + qt_{\frac{\alpha,2}, df=n-d} s.e.(\hat{y_0}),f(x_0|\hat{\beta}) + qt_{1 - \frac{\alpha,2}, df=n-d} s.e.(\hat{y_0})]
$$
where $s.e.(\hat{y_0}) = \sqrt{\nabla f(x_0|\hat{\beta})^T \cdot Cov(\beta) \cdot \nabla f(x_0|\hat{\beta}) + \sigma ^ 2}$ and $\sigma ^ 2 = Var(\hat{e_i})$
</p>

I will create a function which takes the input and response variables, and returns 
a list object containing the fit and the prediction/confidence intervals using the above theory.

```R
library(stats)

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
