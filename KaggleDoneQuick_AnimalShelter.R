###Thoughts right off the bat:
#(1) Dogs and cats are probably different, probably makes more sense to make two separate models (one for dogs and one for cats)
#(2) Breeds probably need to be groups
#(3) age upon outcome is a factor because it's written in the format "1 month," may need to change to something more useful (i.e., continuous)
#(4) Date Time could be useful if it refers to the outcome (not the entry) since animals may be more likely to get adopted at different times of year
#(5) Color probably also needs to be color group
#(6) Are purebreds more likely to be adopted than mixes?

###import data
setwd("~/Documents/Kaggle/AnimalShelter/Data")
d<-read.csv("train.csv")

###separate into dogs and cats

dog<-d[which(d$AnimalType == "Dog"),]
cat<-d[which(d$AnimalType == "Cat"),]

###it's a multinomial logistic regression, because the outcome variable is categorical

library(nnet)

###it's also worth noting that adoption a priori ignoring everything just is the most common, when I played around with the data using SexuponOutcome as a predictor (just to see what the results look like of my multinomial regression, which may secretly be a neural net) it severely overpredicted adoption, perhaps because of this; though it could also be that sex just isn't that correlated with outcome... though a chi-squared test seems to indicate it is... in face X-squared is stronger for Sex than for Color, but Breed is stronger than both when chi-squaring it up

###a fisher test would be more appropriate, but to do that I will have to conquer the big data problem... by which I mean my data doesn't fit

###though, it doesn't really seem like the data are too big due to raw number of rows, so perhaps it's the number of levels that's the problem, if that's the case dog group should help

dog$mutt<-"no"
dog[grep("Mix",dog$Breed),"mutt"]<-"yes"

###would have to account for blanks if there were any but there are not
###hmm fisher still fails on the mutt variable, so it really may be the size of the dataset that's the problem, good to know

dog$pit<-"no"
dog[grep("Pit Bull",dog$Breed),"pit"]<-"yes"

###change sex to two new columns, female versus male and neutered versus intact
dog$sex<-"Unknown"
dog[which(dog$SexuponOutcome==""),"sex"]<-"Unknown"
dog[grep("Female",dog$SexuponOutcome),"sex"]<-"Female"
dog[grep("Male",dog$SexuponOutcome),"sex"]<-"Male"

dog$status<-"Fixed"
dog[which(dog$SexuponOutcome==""),"status"]<-"Unknown"
dog[grep("Intact",dog$SexuponOutcome),"status"]<-"Intact"
dog[grep("Unknown",dog$sexuponOutcome),"status"]<-"Unknown"

###silly way of checking what matters, but run some chi-squares because that works on the big data

chisq.test(table(dog$OutcomeType, dog$mutt))
chisq.test(table(dog$OutcomeType, dog$pit))
chisq.test(table(dog$OutcomeType, dog$sex))
chisq.test(table(dog$OutcomeType, dog$status))

###all highly significant, though mutt least so

mod<-multinom(OutcomeType~mutt + pit + sex + status, data=dog)
mod1<-multinom(OutcomeType~pit + sex + status, data=dog)

###not a significant difference in AIC taking into account muttness, probably because there are so many mutts, so model 1 will do for the dogs, but what about the cats?

###hmm, actually I forgot to look into age and color

###for age, all ages are in years or months, any dog under 1 year probably counts as a puppy, but then there are still young dogs, adult dogs, and senior dogs
#<1 month = infant
#1-6 months =puppy
#7 months - 2 years = young
#2 years - 6 years = adult
#6+ years = senior
dog$ageinfo<-"holding"
dog[which(dog$AgeuponOutcome==""), "ageinfo"]<-"unknown"
dog[grep("day", dog$AgeuponOutcome),"ageinfo"]<- "infant"
dog[grep("days", dog$AgeuponOutcome),"ageinfo"]<- "infant"
dog[grep("week", dog$AgeuponOutcome),"ageinfo"]<- "infant"
dog[grep("weeks", dog$AgeuponOutcome),"ageinfo"]<- "infant"
dog[grep("month", dog$AgeuponOutcome),"ageinfo"]<-"puppy"
dog[grep("months", dog$AgeuponOutcome),"ageinfo"]<-"months"
dog[grep("year",dog$AgeuponOutcome),"ageinfo"]<-"young"
dog[grep("years",dog$AgeuponOutcome),"ageinfo"]<-"years"

###for dogs in "months" those in less than six months should be puppies, and those who are more than six months should be young
###if I wanted to do more specifics with this, this is how I would do it, but I think in the interest of "done quick" I will drop this
#temp2 <- gregexpr("[0-9]+", dog[which(dog$ageinfo == "months"),"AgeuponOutcome"])
#as.numeric((unlist(regmatches(dog[which(dog$ageinfo == "months"),"AgeuponOutcome"], temp2))))
###or do continuous age... gsub for number and unit type and multiply, this will also be an exercise in regular expressions!

dog$ordinalage<-3
dog[which(dog$ageinfo=="infant"),"ordinalage"]<-1
dog[which(dog$ageinfo=="puppy"),"ordinalage"]<-2
dog[which(dog$ageinfo=="months"),"ordinalage"]<-3
dog[which(dog$ageinfo=="young"),"ordinalage"]<-4
dog[which(dog$ageinfo=="years"),"ordinalage"]<-5

summary(multinom(OutcomeType~ordinalage, data=dog))

mod2<-multinom(OutcomeType~pit + sex + status + ordinalage, data=dog)

###for color, probably want all the ones with "/" to be multi color, how many colors will be leftover after that? do I need to further subdivide? or just pull out the black animals?

#color group 1, multi trumps black
dog$colorgrp1<-as.character(dog$Color)
dog[grep("/", dog$Color),"colorgrp1"]<-"multi"
dog[which(dog$colorgrp1=="Tricolor"),"colorgrp1"]<-"multi"
dog[grep("Black", dog$colorgrp1),"colorgrp1"]<-"black"
dog[grep("Brown", dog$colorgrp1),"colorgrp1"]<-"brown"
dog[grep("Red", dog$colorgrp1),"colorgrp1"]<-"red"
dog[grep("Blue", dog$colorgrp1),"colorgrp1"]<-"blue"

chisq.test(dog$OutcomeType, dog$colorgrp1)

mod3<-multinom(OutcomeType~pit + sex + status + ordinalage + colorgrp1, data=dog)
#not much better AIC than mod2, so stick with that
#could do color group 2 where blakc trumps multi but gotta go quick!
#dog[grep("/", dog$Color),"colorgrp1"]<-"multi"

dog$prediction<-predict(mod2, dog)

dog$match<-"no"
dog[which(dog$prediction == dog$OutcomeType), "match"]<- "yes"

length(which(dog$match == "yes"))/15595

length(which(dog$OutcomeType == "Adoption"))/15595

dog$predictionold<-predict(mod1, dog)

###now do the cats!!
###cat pure versus mix
cat$pure<-"yes"
cat[grep("Mix", cat$Breed),"pure"]<-"no"
cat[grep("/", cat$Breed),"pure"]<-"no"
chisq.test(cat$OutcomeType, cat$pure)
#breed does not seem to matter

###cat fur length
cat$hair<-"Unknown"
cat[grep("Shorthair",cat$Breed),"hair"]<-"short"
cat[grep("Longhiar",cat$Breed),"hair"]<-"long"
cat[grep("Medium Hair",cat$Breed),"hair"]<-"medium"
chisq.test(cat$OutcomeType, cat$hair)
#include hair

###sex
cat$sex<-"Unknown"
cat[which(cat$SexuponOutcome==""),"sex"]<-"Unknown"
cat[grep("Female",cat$SexuponOutcome),"sex"]<-"Female"
cat[grep("Male",cat$SexuponOutcome),"sex"]<-"Male"

cat$status<-"Fixed"
cat[which(cat$SexuponOutcome==""),"status"]<-"Unknown"
cat[grep("Intact",cat$SexuponOutcome),"status"]<-"Intact"
cat[grep("Unknown",cat$sexuponOutcome),"status"]<-"Unknown"

chisq.test(cat$OutcomeType, cat$sex)
chisq.test(cat$OutcomeType, cat$status)

#include sex and status

#age
cat$ageinfo<-"holding"
cat[which(cat$AgeuponOutcome==""), "ageinfo"]<-"unknown"
cat[grep("day", cat$AgeuponOutcome),"ageinfo"]<- "infant"
cat[grep("days", cat$AgeuponOutcome),"ageinfo"]<- "infant"
cat[grep("week", cat$AgeuponOutcome),"ageinfo"]<- "infant"
cat[grep("weeks", cat$AgeuponOutcome),"ageinfo"]<- "infant"
cat[grep("month", cat$AgeuponOutcome),"ageinfo"]<-"kitten"
cat[grep("months", cat$AgeuponOutcome),"ageinfo"]<-"months"
cat[grep("year",cat$AgeuponOutcome),"ageinfo"]<-"young"
cat[grep("years",cat$AgeuponOutcome),"ageinfo"]<-"years"

cat$ordinalage<-3
cat[which(cat$ageinfo=="infant"),"ordinalage"]<-1
cat[which(cat$ageinfo=="kitten"),"ordinalage"]<-2
cat[which(cat$ageinfo=="months"),"ordinalage"]<-3
cat[which(cat$ageinfo=="young"),"ordinalage"]<-4
cat[which(cat$ageinfo=="years"),"ordinalage"]<-5

multinom(OutcomeType~ordinalage, data=cat)

###color, are black cats less likely to be adopted

cat$black<-"no"
cat[grep("Black", cat$Color),"black"]<-"some"
cat[which(cat$Color == "Black"),"black"]<-"all"

cat$ordblk<-0
cat[which(cat$black == "some"),"ordblk"]<-1
cat[which(cat$black == "all"), "ordblk"]<-2

multinom(OutcomeType~ordblk, data=cat)

###models

mod<-multinom(OutcomeType~hair + sex + status, data=cat)
mod1<-multinom(OutcomeType~hair + sex + status+ordinalage, data=cat)
mod2<-multinom(OutcomeType~hair + sex + status+ordblk, data=cat)
mod3<-multinom(OutcomeType~hair + sex + status+ordinalage+ordblk, data=cat)

###don't includ black, do include age, model 1

cat$prediction<-predict(mod1, cat)

###wow, cat model is way worse than dog model, but more rushed so meh