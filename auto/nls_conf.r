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

