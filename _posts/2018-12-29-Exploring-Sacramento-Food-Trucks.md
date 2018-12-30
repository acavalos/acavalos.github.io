---
published: true
---
Over the past decade, the food truck industry had a big bang type expansion. Despite battling different regulations and 
ordinances throughout California, truck owners have proven the viability of taking food service from brick-and-mortar to 
the streets. In the Sacramento area, a large handful of trucks emerged to become local favorite such as Chando's Taco's. 
In this post I will take a brief look at the yelp performance of all trucks and explore potential attributes that significantly 
affects how users review mobile vendors. 

# Motivation
You may be telling yourself, 'Well duh, obviously the food and customer service attributes 
to user scores.' You're probably right. But this project is mainly to brush up on methods I already know in R, 
and practice them in Python. If you are looking for hardcore statistical methods, you will not find that here. 
Instead, I offer some exploratory analysis.

# The Data
After exploring the layout of Yelp, I opted to create two different data frames. 
A frame("yelp_review_final.csv") containing the review data for each vendor, and a frame("yelp_user_final.csv") containing user information.
The information was scraped using the Scrapy package for Python, sorting through vendors in Sacramento containing the tag 'Food Truck'. 

If you would like the code for the Scrapy spider, you can contact me. It is versatile enough to scrape reviews for any vendor.

You can find all the datasets [here](https://github.com/acavalos/yelp_food_truck).
# Truck Performance

Let's see which trucks are the most popular, well-reviewed, and those that are poorly reviewed.

<script src="https://gist.github.com/acavalos/557f72fc281241fda9b234044f4e84a7.js"></script>

## Sorted by number of reviews

|business_name|review_stars|count|
|:------------------------------------|:-------------|:----|
|        Kado’s Asian Grill Food Truck  |    3.952381  |   84|
 |         SacYard Community Tap House   |   4.522222  |   90|
 |                           Cichy Co    |  3.789474  |   95|
 |  Flavor Face Mobile Food & Catering    |  4.145161 |   124|
 |                      Wandering Boba    |  4.080645   | 124|
 |                     Mama Kim Cooks     | 4.293333   | 150|
 |                    Slightly Skewed   |   4.194969   | 159|
 |              La Mex Taqueria Truck    |  3.350000   | 160|
 |                          SactoMofo     | 3.715116   | 172|
 |                  Bacon MANia Truck      |3.693642   | 173|
 | Cousins Maine Lobster - Sacramento     | 3.751244  |  201|
 |                     Squeeze Burger     | 3.382263    |327|
 |          Drewski’s Hot Rod Kitchen     | 3.892774   | 429|
 |                        Hefty Gyros     | 4.733607  |  488|
 |                    Chando’s Tacos     | 4.215100  | 1841|
 
 Immediately, we see Chando's Taco's are far and away more popular than the even the next few vendors. 
 This is likely due to Chando's not having a seperate Yelp page dedicated to their brick-and-mortar locations.
 We will also have this issue with Squeeze Burger as a good portion of their reviews feature users 
 who are not sure which page of theirs to post their review at. I will choose to leave these two vendors regardless.
 Interesting enough, Hefty Gyros not only is the second most reviews, but has an extremly high review average. We will revisit this later.

 
## Top 15 Reviewed Trucks With At Least 10 Reviews

|business_name|review_stars|count|
|:----|:----|:----|
|SacYard Community Tap House|4.522222222222222|90|
|India Jones|4.586206896551724|58|
|Luciano’s Scoop|4.604651162790698|43|
|Paul’s Rustic Oven|4.625|16|
|Voyager World Cuisine|4.647058823529412|34|
|Paquitas Mexican Grill|4.709677419354839|62|
|Hefty Gyros|4.733606557377049|488|
|Who is Hungry? Foodtruck|4.75|24|
|Carlos Mejia’s Curbside Kitchen|4.7560975609756095|41|
|Mee Mahs Mediterranean Grill|4.777777777777778|18|
|Big Shrimp’n Low Country Boil Truck|4.785714285714286|14|
|Bambi|4.821428571428571|56|
|Local Kine Shave Ice|4.823529411764706|34|
|Frutazo|4.875|16|

## Bottom 15 Reviewed Trucks

|business_name|review_stars|count|
|:----|:----|:----|
|All Angle BBQ|1.1428571428571428|7|
|Cool Dogz|2.0|4|
|Ganesh Fine Indian Cuisine|2.3333333333333335|6|
|New Bite|2.4193548387096775|62|
|Latin Flame|2.5|8|
|Cali Love Food Truck|2.657142857142857|35|
|Azteca Street Tacos|2.7142857142857144|56|
|Fil-Gud|2.8|30|
|Squeeze Inn Food Truck|3.125|8|
|La Mex Taqueria Truck|3.35|160|
|Squeeze Burger|3.382262996941896|327|
|Squeeze Inn Truck|3.40625|32|
|Salo’s kitchen & Grill|3.4166666666666665|12|
|Falafel Me|3.4285714285714284|14|
|El Matador Mobile Mex|3.4827586206896552|58|

Looking back at the most reviewed trucks, it's interesting to see Squeeze Burger appear here as well as La Mex Taqueria. 
La Mex's claim to fame is its longevity, having its first review in 2009, well before the majority of current mobile vendors. 

## Total Market Performance and Its Main Contributors

I'm interested in seeing the average yelp review for trucks over time. It'd be interesting to also see monthly averages 
and volume. One of my favorite plots types are candlestick charts for securities such as stock plots. This type of plot is perfect 
for our purposes. I opted to keep lines, instead of candlesticks. 

<details>
<summary> <b>Plot Code (CLICK ME)</b> </summary>

<script src="https://gist.github.com/acavalos/ee15d65389d5a3f6a89be6b241ca9d72.js"></script>

</details>

<p align = "center">
<img src="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/Total_Performance.png" width="700"/>
</p>

That was quite a bit of code(I'm sorry for using the iterrow() method... But we only have 6000 rows so its fine), but I'm happy with the output. 
From my knowledge, the peak era of food trucks was 2013-2015. It's interesting to see the volume steadily increasing over time. 
Annually, we see peak volume during summer as one would expect. 

While number of reviews increase, we see the average truck has effectively converged to about 4.1. Due 
to the sheer number of reviews already made, it is unlikely that this average will change by a large margin, 
save for a collapse of the market. 

If we look at the size of our review frame, we see half of the reviews come from the five most popular trucks. 
Let's take a look their plots.

<details>
<summary> <b> Plots (CLICK ME) </b> </summary>
    <p align = "center">
        <img src="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/Chandos_Tacos.png" width="400" />
        <img src="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/Hefty_Gyros.png" width="400"/>
        <img src="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/drewskis.png" width="400"/>
        <img src="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/Squeeze%20Burger.png" width="400"/>
        <img src="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/cousins_maine.png" width="400"/>
    </p>
</details>

A lot of interesting effects happening amongst the top five trucks. Chando's and Drewski’s appear to be underperforming 
for the past two years. Luckily for them, the majority of their reviews are from 2011-2016 where they were definitely fan favorites. 
Drewski's is at risk to drop tiers by 2020 if they allow themselves to continue tanking. Their only saving grace is their yelp 
page has such low amount of traffic after the summer of 2016.

Squeeze Burger seems to consistently underperform while Cousins Maine looks to be slowly becoming mediocre. 

The real interesting information to focus on is Hefty Gyros. If we browse each individual trucks plots, we notice similar trends. 
Trucks yelps are rarely consistent over time. Either a truck starts strong and dies a slow death, or the opposite. Only a few trucks 
feature a flat, consistent line. But Hefty Gyros, sporting an average 4.7(this is insane for Yelp), has managed to be the highest rated truck while 
staying consistent since late 2014? Truly impressive stuff. 

# User Analysis

Yelp features premium accounts titled "Yelp Elite", awarded to users who use the site heavily. I'd like to see 
how Elite members review compared to non-Elite members.

<script src="https://gist.github.com/acavalos/50ac15edc61ba1663eab350251555a67.js"></script>

Out of the 4736 users, about 1/5 are Elite members. 

<script src="https://gist.github.com/acavalos/2a7cfb40935ce0e2d5c49cc40fefb680.js"></script>
<p align="center">
    <img src="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/elite.png" width="450" />
</p>

Amazingly, Elite members contribute almost twice as many reviews than non-elite members, despite only accounting for 20 percent 
of the pool of users. 

<script src="https://gist.github.com/acavalos/0cffd6b19c02716a0cf918bd558eb72b.js"></script>

We see Elite members are 40-50% more likely to give 3 or 4 star reviews. Moreover, 
they are a lot less like to give a 1 star review.

Elite membership aside, there may be a correlations between review average, user friend count, user review count, and user review vote counts.
For this, we can make a simple heatmap.

<script src="https://gist.github.com/acavalos/c00df4233b19c1e20142bb0dc0c63994.js"></script>

<p align="center">
    <img src="https://raw.githubusercontent.com/acavalos/acavalos.github.io/master/images/heat.png" width="450" />
</p>

There appears to be no correlation between the social attributes of the user and how the user 
is likely to review in general. 


# Review Text Analysis

Next, we will mine the review content to find key words correlated to the users review score.
First, we need to transform the text to something easier to work with.

<script src="https://gist.github.com/acavalos/c5dd9ee5705cb7506740ea11847bfb93.js"></script>

We see 5017 words appear only once. We will go ahead and remove those as well.

<script src="https://gist.github.com/acavalos/9dfa60cae6b826a3d25f8c4808560449.js"></script>

Deleting rare words took a hot minute compute, so I am positive there is a faster solution to this.

The next step is to perform Sentiment Analysis. For this we can utilize the 'sklearn' package. 
Typically, Logistic Regression is used for classification. 95% of the time, we use it to build 
a classifier that will later sort new information. Instead, we will be using it as a means to associate 
words with a good or bad review. Remember, like Linear Regression, the 
magnitude of coefficients imply larger effects the word has on the review outcome. For this reason, 
we will sort the coefficients and review the greatest and least values.

<script src="https://gist.github.com/acavalos/9ce979da9a887c5b7ed691b7e890b277.js"></script>


|worst|best|
|:------|:------|
|('worst', -2.17)|('amazing', 2.21)|
|('overpriced', -1.62)|('delicious', 1.87)|
|('mediocre', -1.56)|('awesome', 1.65)|
|('dry', -1.54)|('loved', 1.48)|
|('terrible', -1.3)|('great', 1.35)|
|('looks', -1.28)|('tasty', 1.35)|
|('gross', -1.27)|('full', 1.34)|
|('bland', -1.26)|('happy', 1.26)|
|('soggy', -1.22)|('yummy', 1.26)|
|('sorry', -1.22)|('best', 1.24)|
|('poor', -1.21)|('perfect', 1.22)|
|('undercooked', -1.19)|('tender', 1.21)|
|('awful', -1.17)|('definitely', 1.18)|
|('couldnt', -1.15)|('excellent', 1.18)|
|('flavorless', -1.15)|('glad', 1.14)|
|('werent', -1.15)|('favorite', 1.09)|
|('skip', -1.13)|('lamb', 1.08)|
|('yuck', -1.12)|('youre', 1.07)|
|('grid', -1.11)|('bomb', 1.04)|
|('impressed', -1.11)|('friends', 0.99)|
|('lacked', -1.11)|('come', 0.98)|
|('water', -1.09)|('enjoyed', 0.95)|
|('disappointed', -1.07)|('often', 0.94)|
|('disappointing', -1.06)|('especially', 0.93)|
|('waiting', -1.05)|('little', 0.92)|
|('rude', -1.04)|('green', 0.9)|
|('alright', -1.03)|('fantastic', 0.87)|
|('disappointment', -1.02)|('die', 0.86)|
|('gone', -1.02)|('yum', 0.85)|
|('pay', -1.02)|('asian', 0.84)|


There are some key topics to pull from this information. 
Customer reviews are affected by: unsatisfactory food, cost of the food, or poor service from 
truck operators. Well duh.

Moving forward, let's do some topic modeling.

The common techniques used for Topic Modeling are Non-Negative Matrix Factorization and Latent Dirichlet Allocation. 
I will choose to use NMF. I've tried LDA and found NMF provided better topics. I also removed Chando's reviews from 
the input as they affect the topics too much.

<script src="https://gist.github.com/acavalos/db2650ec378c57ce093915ab34314a50.js"></script>

|Topic|
|:----|
|Topic #0: order would get minutes like dont im one didnt line took 10 waiting know back|
|Topic #1: cheese mac grilled crab balls watermelon hemi face flavor bread fried sandwich cheesy inside pulled|
|Topic #2: lobster roll maine rolls connecticut tots bisque cousins chowder mayo shrimp worth small warm ordered|
|Topic #3: great food service beer job prices setting eric selection atmosphere flavor experience price wish options|
|Topic #4: lamb beef frankie tried say eat curry gyro tender plate samosas loved india combo jones|
|Topic #5: burger cheese skirt patty burgers bun big joint fries better place cooked regular like even|
|Topic #6: tacos fish street chips truck shrimp fresh potato sweet steak mex mexican minced menu two|
|Topic #7: chicken salad rice jerk teriyaki flavor plate bowl fried sammich special spicy comes juicy tasty|
|Topic #8: fries loaded garlic salty cheese crispy ordered blue hefty potato truffle pita special asiago order|
|Topic #9: bacon mac mania wrapped sliders cheese blt piggy brownie truck brownies fries hog thing top|
|Topic #10: food truck trucks quality prices price looking filipino fresh mania mediocre amount get mexican area|
|Topic #11: wedding mama party us guests catered kim event everyone carlos everything catering kims cater food|
|Topic #12: always every get go fresh favorite truck ice come food well stop consistent run look|
|Topic #13: burrito meat salsa mexican beans super sour california cream burritos like carnitas adobada 10 size|
|Topic #14: lumpia pancit adobo shanghai filipino sisig rice plate boba vegetable wandering ordered sarap order side|
|Topic #15: gyro pita hefty meat rice lamb spicy market truck ultimate farmers special tzatziki fries get|
|Topic #16: love get new come especially must food know thank best everyone crave much masa times|
|Topic #17: tri tip tender sandwich mama loaded kim bbq well chips garlic potato truck lunch flavorful|
|Topic #18: good pretty prices food bit salsa nice though everything service little eat sooo really think|
|Topic #19: rice balls fried skewers beans skewer green smashed teriyaki asparagus bulgogi scallion chicken skewed sticky|
|Topic #20: sandwich bread grilled mustang chips sweet potato sandwiches truck prius kimchi cheese drewskis ordered meat|
|Topic #21: friendly super staff fast clean nice helpful family quick depot tasty truck work greatest food|
|Topic #22: hefty gyros pita fries gyro truck eric every eating best forward favorite portion choices well|
|Topic #23: taco vegan tacos bambi masa beef chorizo truck korean la farmers tortillas mexican tortilla market|
|Topic #24: place beer go beers tap new like fun nice cool dont youre space outside lots|
|Topic #25: amp mac well sure hemi truck work forrrrr crew 50 today sweet everybody went right|
|Topic #26: event trucks people lines line long park parking food many one music sactomofo sacramento year|
|Topic #27: awesome truck food clean service friendly back artichoke also burgers grilled make crew employees great|
|Topic #28: time first tried last next trying every today ordered night ill also truck eating mania|
|Topic #29: pizza dust flour pizzas crust oven mano paul pepperoni guests event 10 italian made recently|
|Topic #30: recommend highly would everyone anyone excellent party food recommended flavorful service fresh enjoyed flavor clean|
|Topic #31: amazing food absolutely everything thank go wow owners never theyre catered staff cali chowder eaten|
|Topic #32: sauce meat spicy flavor top tender cooked bbq also little well extra hot ordered fresh|
|Topic #33: tea boba milk sweet thai wandering ice popcorn drinks drink lumpia also like green flavors|
|Topic #34: tots garlic hemi drewskis rosemary tater mustang sweet sandwiches tricycle grilled potato drewski sandwich prius|
|Topic #35: try menu items must wings everything truck next give decided something glad sandwiches different one|
|Topic #36: dog hot dogs wrapped ice drewski like baja bun beer shaved one drewskis come chili|
|Topic #37: nachos nacho chips half quality 12 beans better vegan truck black ordered toppings cheese gave|
|Topic #38: definitely back come coming pita ill worth trying going would go tried one recommend bread|
|Topic #39: guys thank work thanks working dudes smells coolest quickly much nice sure see made making|
|Topic #40: service customer quick food excellent friendly great fast thank defiantly bomb stars awesome back amazing|
|Topic #41: falafel pita salad rice plate yummy side tasty wrap lettuce lunch baklava flatbread tomatoes tasting|
|Topic #42: got 10 husband came didnt finally truck ate us daughter like back wife huge see|
|Topic #43: really like nice good enjoyed tasty nothing im track ive people things didnt get pita|
|Topic #44: wait cant next fish worth long yum try loved event omg minutes truck get tried|
|Topic #45: best ever ive one hands sacramento far seriously tried recommend hemi tasted town truck gelato|
|Topic #46: pork pulled belly hemi bbq mac beef sisig sliders order sweet truck cichy onions half|
|Topic #47: asada carne tacos carnitas salsa ordered taco mexican meat cilantro fast pastor us two al|
|Topic #48: squeeze cheese skirt inn location burgers burger original midtown dont like back fruitridge restaurant bun|
|Topic #49: delicious fresh absolutely fast food everything eat lunch friendly perfect italian made also yummmm quick|


Most of the topics are clearly associated with certain trucks. Howerver, there are still a few topics regarding food 
service. What I would like to do moving forward is to 
project each truck onto the topic space, and then rank them based on the topics associated with food service. 
That is, let's find out which trucks, from 2017 and on, are most associated with topics 18,21,31,40.

Each truck is scored as follows:
1. Each review is projected onto the topic space.
2. Sum the coefficients of all the relevant topics.
3. Multiply this sum by -1 or 1 based on sentiment of review.
3. Add or subtract this sum to the trucks total score.
4. Finally, divide this statistics by number of reviews for truck.

<script src="https://gist.github.com/acavalos/c22d57c640f75224b3bbae026d55aaf4.js"></script>

|business_name|count|total|
|:------|:------|:------|
|Chocho’s Tacos Truck|18|0.05103463253691082|
|Ahuevo Foods|25|0.04195886402981226|
|SacYard Community Tap House|89|0.041509267694402455|
|Frutazo|16|0.04017075518142534|
|Voyager World Cuisine|16|0.03870888571477729|
|Carlos Mejia’s Curbside Kitchen|26|0.038375350175482846|
|Luciano’s Scoop|16|0.03781389839869229|
|Flour Dust Pizza Co|23|0.03760721444247645|
|Ma Sarap Food Truck|68|0.03640614503406595|
|Hefty Gyros|228|0.03443518417723854|
|Tina’s Tacos & Catering|18|0.03239764365902059|
|India Jones|58|0.030161364301139717|
|Paquitas Mexican Grill|58|0.028636750978992362|
|Concerts In the Park|36|0.0282118796348868|
|Mee Mahs Mediterranean Grill|18|0.027403297290977995|
|Wandering Boba|38|0.027300952079413684|
|It’s Nacho Truck|32|0.027257855122857465|
|Squeeze Burger|89|0.026794983390727736|
|Che Buono|52|0.02535188326750779|
|Tailgater44 Food Truck|23|0.024960865233055133|
|GyroStop|20|0.024734676026114653|
|Nash & Proper|60|0.02381245568047047|
|Kado’s Asian Grill Food Truck|46|0.023249043181445876|
|Slightly Skewed|57|0.0228982032499514|
|Sexy Panda|27|0.02277535114932905|
|Saucy Lito’s|29|0.02263259061438895|
|La Mex Taqueria Truck|57|0.021599181283027784|
|Flavor Face Mobile Food & Catering|42|0.021498014315062052|
|Chando’s Tacos|430|0.021464174135112347|
|Masa Guisería|56|0.02102125784575848|
|Food Truck Cinema|18|0.020890861130787156|
|Gyro 2 Go|19|0.020238281288935338|
|Turnt Up Food Truck|26|0.02011762376984647|
|Bacon MANia Truck|33|0.019941059748076057|
|Who is Hungry? Foodtruck|19|0.01904498989194018|
|The Pop Up Truck|28|0.01757878192687607|
|The Pizza Plug|18|0.014001172622595728|
|Smoothie Patrol|24|0.012704678020140258|
|Cichy Co|28|0.01229818755296032|
|Bambi|54|0.011829663708775313|
|Cousins Maine Lobster - Sacramento|77|0.011820582534769183|
|Fil-Gud|30|0.008534176150693679|
|Azteca Street Tacos|34|0.0045932632100829495|
|Drewski’s Hot Rod Kitchen|64|0.004169457614719875|
|New Bite|16|-0.02036737501473408|

It has not occured to me until now that a Tap House was mixed in. Upon reviewing their yelp, they do 
have a 'Food Truck' tag, which explains why my scraper picked it up. Regardless, we can choose to ignore it. 

Looking at this list, we see some issues with major vendors. From earlier we have found the industries yelp 
reviews are largely dominated by Chando's, Drewski's, Cousin's, and Hefty Gyros. Since this list ranks 
sentiment on service quality, it is worrying to see Drewski's second to last and Cousin's Maine not too far ahead. 


# Conclusions
1. If I were to restart this project, major changes I would make would be to expand the scope of it. There are too 
many vendors with small amounts of reviews. Moreover, we could investigated how brick-and-mortar compares to 
the mobile industry. I would also re-evaluate how I rank trucks based on their service provided. While I believe my 
statistic is a good start, it is biased towards well-reviewed trucks and can't account for scenarios where service may 
have been good, but the food was bad. 

2. Although elite yelpers account for a significantly smaller fraction of the userbase, 
they contribute almost twice as many reviews as the non-elite. Moreover, they also are more likely to 
submit a positive review. This is most likely do to user bias towards reacting to a negative experience. 
We found no significant effects of user social attributes(number of friends, number of reviews, votes submitted) 
towards review scores.

3. Among the most reviewed trucks, there has been an obvious decline in sentiment among Chando's Tacos and Drewski's. 
For Drewski's, declining quality of service may be the telling factor for the past two years. 

4. Mobile vendors need to focus on providing value. As any food truck regular knows, food truck prices are relatively high. 
When new customers, or even regulars, agree to pay for higher prices, they expect everything to be on point. 
The service must be at least decent, and the food must be served to standard. Higher prices combined with poor food quality and/or 
service results in scathing reviews. This can be mitigated if vendors could find ways to provide food at a lower cost 
to its consumers, or invest their money into experienced operators that can provide adequate service.
