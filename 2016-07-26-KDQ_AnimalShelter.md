---
layout: post
title: "Kaggle Done Quick: Animal Shelter"
date: 2016-07-26
author:
 - abbiepopa
---
This is the first post in what will hopefully become a series. For this project I wanted to see how far I could get with a kaggle dataset in under four hours. Because the topic interested me, I dove into Kaggle's [animal shelter](https://www.kaggle.com/c/shelter-animal-outcomes) dataset.
<br><br>
For this dataset, kaggle asks that you predict which dogs and cats will have each of five outcomes: Adoption, Died, Euthanasia, Return to Owner, and Transfer. Potential predictors include Animal Type (dog versus cat), breed, color, sex, and age. For a first attempt I decided to use multinomial logistic regression. The possible outcomes are discreet and unordered, which is what multinomial logistic regression was designed to predict. I performed said regressions using the nnet package for R.
<br><br>
The first decision I made was that separate models were necessary for dogs and cats, given that they are literally different animals. It is definitely not necessary that dogs and cats would have the same predictors.
<br><br>
//picture of Ripley to break up all the text
<br><br>
A quick examination of the data yields a few important findings for preprocessing. First, there are 1380 dog breeds alone. This is far too many categories to be useful for a model. Based on real world experience I rebinned the breeds as dogs who were pit bulls, dogs who were mutts, and dogs who were pure bred. In the final model I tested the prediction power of being identified as a mutt and as a pit bull and only pit bull significantly increased AIC of the model. In fact, being a pit bull was the strongest predictor in my data set. With pit bulls much more likely to receive euthanasia and much less likely to be adopted. This is an actionable insight from these data. Perhaps shelters could organize educational endeavors to reduce the stigma associated with pit bulls. Or offer potential owners obedience training for their pit bulls.
<br><br>
//picture of an adoptable pit bull at YCAS
<br><br>
