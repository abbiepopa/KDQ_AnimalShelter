###import data
setwd("~/Documents/Kaggle/AnimalShelter/Data")
d<-read.csv("test.csv")

###separate into dogs and cats

dog<-d[which(d$AnimalType == "Dog"),]
cat<-d[which(d$AnimalType == "Cat"),]

###it's a multinomial logistic regression, because the outcome variable is categorical

library(nnet)



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

dog$ordinalage<-3
dog[which(dog$ageinfo=="infant"),"ordinalage"]<-1
dog[which(dog$ageinfo=="puppy"),"ordinalage"]<-2
dog[which(dog$ageinfo=="months"),"ordinalage"]<-3
dog[which(dog$ageinfo=="young"),"ordinalage"]<-4
dog[which(dog$ageinfo=="years"),"ordinalage"]<-5


###for color, probably want all the ones with "/" to be multi color, how many colors will be leftover after that? do I need to further subdivide? or just pull out the black animals?

#color group 1, multi trumps black
dog$colorgrp1<-as.character(dog$Color)
dog[grep("/", dog$Color),"colorgrp1"]<-"multi"
dog[which(dog$colorgrp1=="Tricolor"),"colorgrp1"]<-"multi"
dog[grep("Black", dog$colorgrp1),"colorgrp1"]<-"black"
dog[grep("Brown", dog$colorgrp1),"colorgrp1"]<-"brown"
dog[grep("Red", dog$colorgrp1),"colorgrp1"]<-"red"
dog[grep("Blue", dog$colorgrp1),"colorgrp1"]<-"blue"


dog$prediction<-predict(mod2, dog)
write.csv(dog, "dog_test.csv", row.names=F)

###now do the cats!!
###cat pure versus mix
cat$pure<-"yes"
cat[grep("Mix", cat$Breed),"pure"]<-"no"
cat[grep("/", cat$Breed),"pure"]<-"no"
#breed does not seem to matter

###cat fur length
cat$hair<-"Unknown"
cat[grep("Shorthair",cat$Breed),"hair"]<-"short"
cat[grep("Longhiar",cat$Breed),"hair"]<-"long"
cat[grep("Medium Hair",cat$Breed),"hair"]<-"medium"
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


###color, are black cats less likely to be adopted

cat$black<-"no"
cat[grep("Black", cat$Color),"black"]<-"some"
cat[which(cat$Color == "Black"),"black"]<-"all"

cat$ordblk<-0
cat[which(cat$black == "some"),"ordblk"]<-1
cat[which(cat$black == "all"), "ordblk"]<-2

###don't includ black, do include age, model 1

cat$prediction<-predict(mod1, cat)

###wow, cat model is way worse than dog model, but more rushed so meh

write.csv(cat, "cat_test.csv", row.names=F)

###format for submission
rm(list=ls())
submit<-read.csv("sample_submission.csv")
cat1<-read.csv("cat_test.csv")
dog1<-read.csv("dog_test.csv")
cat1<-cat1[,c("ID","prediction")]
dog1<-dog1[,c("ID","prediction")]

test<-rbind(cat1,dog1)

test$Adoption<-0
test$Died<-0
test$Euthanasia<-0
test$Return_to_owner<-0
test$Transfer<-0

test[which(test$prediction == "Adoption"),"Adoption"]<-1
test[which(test$prediction == "Died"),"Died"]<-1
test[which(test$prediction == "Euthanasia"),"Euthanasia"]<-1
test[which(test$prediction == "Return_to_owner"),"Return_to_owner"]<-1
test[which(test$prediction == "Transfer"),"Transfer"]<-1