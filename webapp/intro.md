## Language Identification Using Random Forests ##

This web app lets you analyze the results from using a radom forest to identify the language of sentences. You can choose different views of the data by clicking the tabs above.

* The **No. of Examples** tab lets you investigate how in-sample and out-of-sample accuracy varies with the number of training examples (for a fixed number of features).

* The **No. of Features** tab is similar but shows how accuracy varies with the number of features (for a fixed number of training examples.

* The **Error Analysis** tab shows the sentences that were incorrectly classified by the best performing classifier.

## Experimental Setup ##

This experiment is inspired by the TextCat algorithm was published in the paper [N-Gram-Based Text Categorization](http://odur.let.rug.nl/vannoord/TextCat/textcat.pdf) by Cavnar and Trenkle. For this experiment we did not use the actual TextCat algorithm. Instead we use random forests but the features we fed to the random forests were inspired by TextCat. Therefore it makes sense to briefly look at the TextCat algorithm.

### TextCat ###
The TextCat algorithm is quite simple but performs extremely well. In very broad terms, the algorithm creates a *profile* for each known language. Then, when a new text is to be classified, a profile is created for that text and compared to the profile for each known language to calculate a distance between the language profile and the profile of the new text. The language with the least distance to the new text is the predicted language of the text.

The profiles are (character) N-gram based and are basically top-lists of N-grams found in the text. You can think of a character N-gram as substring of length N. A minimum and a maximum N is chosen and then all N-grams within that range of Ns is created and counted. If, for example, we choose N between 1 and 3, all substrings of length 1 to 3 is extracted from the text. As an example, let's create all N-grams of N between 1 and 3 for a Danish text. When using TextCat, we would normally use longer texts than a single sentence but for brevity we will create an example with one sentence only.

Let's take the Danish text `Jeg spiser rødgrød med fløde`. The 1-grams we can create from this text are just every single character, `J`, `e`, `g`, `_`, `s`, `p` and so on. Note that the whitespace was converted to a underscore. This is just for readability's sake. The 2-grams would be `Je`, `eg`, `g_`, `_s`, `sp` and so on. Last, the 3-grams would be `Jeg`, `eg_`, `g_s`, `_sp` and so on. Finally we count the occurences of each n-gram. For example, the n-gram `ød` appears 3 times in the text while `i` appears only once. We can now sort the list of n-grams by their frequency in descending order. The X most frequent n-grams make up our profile for that text. X is a value found experimentally, for example 200.

Initially a profile is created for each language that the system must be able to identify. Ideally this is done on a rather long text.

When comparing the profile of a language to that of a new piece of text, the rank of each N-gram is compared between the two profiles. For example if one N-gram is the top item in the language profile but the 3rd item in the text profile, there's a rank difference of 3-1 = 2. The sum of differences for each N-gram is the distance between the two N-grams. For further details, see the [original paper](http://odur.let.rug.nl/vannoord/TextCat/textcat.pdf) by Cavnar and Trenkle.

### Random Forests ###
One caveat of the TextCat algorithm is that it performs less well on very short texts. This is not very surprising, and obviously, if the texts are very short it is sometimes impossible to determine the language since a sentence can be valid in more than one language. 

For this project, we wanted to see how good an accuracy we could get by predicting on very short texts, namely sentences. We decided to use random forests for the prediction. To do this, we needed to create features from the sentences, and this is where the inspiration from TextCat comes in since we used N-gram profiles to calculate our features.


Before we started training, we chose 2000 N-grams which we used for the basis of our features. Each feature is the relative frequency of one of the 2000 N-grams. For example, if the sentence is "*Jeg spiser rødgrød med fløde*", and one of our 2000 N-grams is `ød`, the relative frequency of `ød` is `3 / total_2_grams_in_sentence`. This results in a value between 0 and 1. Doing this for all 2000 chosen N-grams yielded a training and test set with 2000 features.

It is not completely trivial to choose the 2000 N-grams used for the features. One initial idea may be to choose the 2000 most frequent N-grams across all languages. But if an N-gram is frequent for all languages, it is not a very good predictor for what language a text is. We might then think of using the *least* frequent N-grams but this comes with the obvious problem that since the N-grams are rare, most sentences will not contain them and thus we will have to include many features to increase the change that the sentence actually contains some of the N-grams. The approach we chose was to initially pick an N-gram with a high variance across the languages and then keep adding N-grams that have both high variance across the languages and low covariance with the already chosen N-grams.

The preprocessing step which both determined what features to use and calculated the value of each feature for both training and test data was done in C#. The training and prediction using the random forest was done in R using the Caret package. This web app was created using R and Shiny. The R code for the training and prediction as well as the R code for this web app is available on GitHub [here](https://github.com/sorenlind/DataProductsLanguageIdentification).

### Data ###
The texts we chose to use for training and testing are from European Parliament Proceedings. These are available in the following 11 languages:

* Danish
* Dutch
* English
* Finnish
* French
* German
* Greek
* Italian
* Portuguese
* Spanish
* Swedish

They are freely available [here](http://nltk.ldc.upenn.edu/packages/corpora/). More info is available [here](http://www.statmt.org/europarl/).


