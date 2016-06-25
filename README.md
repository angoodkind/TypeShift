### TypeShift: A User Interface for Visualizing the Typing Production Process

https://angoodkind.shinyapps.io/TypeShift/

#### Introduction
The task of “visualizing language production” is both broad and difficult to execute conclusively. Common visualizations relating to language production include word clouds and frequency counts. These summary visualizations, however, only provide a static picture of language. They do not capture the dynamics elements that go into the process of language production, however.

Capturing the dynamics of language production is important because information is transmitted in language not only via the words chosen, but also by tone of voice, pauses and slips of the tongue. Therefore, in order to accurately study language production, a researcher not only needs a record of the words that were produced, but also a record of how they were produced.

The TypeShift tool aims to visualize the dynamics of language produced via a computer keyboard. Compared to speech production data, keyboard typing production data is relatively easy to capture. A simple keylogger can record when a key is depressed and then released, as well as the cursor position. Similar timing metrics are much more laborious and ambiguous with speech production data, as it is more difficult to determine when each sound in a speech stream begins and ends. Nonetheless, the TypeShift tool can be readily adapted to speech data, with only minor alterations.

The importance of a tool such as TypeShift is that it can help answer the question, “What kind of typing session is being produced?” This question is broad and difficult to answer definitively. However, certain aspects of a typing session can shed light on the question, and provide partial answers. Below is a list of the elements of a typing session that TypeShift can held to light on:

 - Is this particular typist fast or slow, as compared to the general population?
 - Is this particular typist fast or slow, as compared to similar language users, e.g. other native English speakers?
 - Does this particular typist produce language at a consistent rate, or do they type in bursts of quick typing interspersed with slow typing?
 - Does this particular typist make a number of revisions during the typing process, whether from mistakes and typographical errors, or from word changes?
 - Given a particular typing session, how does the particular session compare to the typist’s overall production? Is this a relatively fast or slow typing session, for this particular typist?
 - Given a particular typing session, how does it compare to other typists who have also produced answers to the same typing prompt?
 - Given a particular typing session, how does it compare to other typists who have also produced answers to typing prompts that require a similar amount of cognitive effort?
 - Given a particular token in a typing session, how do the pauses preceding each keystroke compare to the overall distribution of typist pauses?

Answers to these questions can be useful in tasks such as training a machine learning classifier. If a particular typing session is being used to train a classifier, as part of a hand-curated development set, a researcher would want to know what kind of data she is dealing with, in order to tune parameters based on the data. In addition, a cognitive scientist could use the tool to visualize how different linguistic structures affect processing, vis-à-vis pauses and production rates. 

Finally, by being able to compare different trends, look at only certain linguistic elements and then be able to see the details of just one token, the TypeShift tool follow’s Ben Shneiderman’s mantra, “Overview first, zoom and filter, then details-on-demand.” (Shneiderman, 1996)

#### Background

Keystroke dynamics is the science of capturing the detailed timing information of a typist’s keystrokes (Moskovitch, 2009). This timing information can vary from a parameter as large as the overall mean typing rate to a metric as minute as the pause time between two particular keys. The details of a typing session can help predict many personal properties, from overall identity authentication (Ali, et al. 2015, and sources within) to emotion and cognition prediction (Epp, et al, 2011).

Pausing within language production can also be especially informative. A pause can signal anything from increased cognitive effort, due to performing lexical retrieval (Erman, 2007), to a more intense focusing on the task at hand (Schilperoord, 1996).

Given that the dynamics of typing can provide such a large amount of information, many researchers have devised methods to visualize a typing session. For a recent overview, see Becotte, et al. (in press). Many of the visualization techniques proposed for the typing process are limited to the “what” of typing, i.e. which keys were pressed and in what order. Some visualizations do focus on the rate of typing, which is reflected as a line chart where a steeper slope reflects a more rapid typing rate. This is illustrated in Figure 1, which is an example of an LS Graph (Lindgren & Sullivan, 2002). However, this visualization I only a continuous line, and lacks a discrete representation of separate words.

![](http://i.imgur.com/p3bsHbG.png "LS Graph")

*Figure 1 - Linear representation of the typing production process*

One visualization technique that does represent word tokens can be seen in Figure 2 (Caporossi & Leblay, 2011). While the discrete nodes show word tokens as well as the relationship between the order in which tokens were produced, this visualization fails to capture the temporal dynamics or varying rates of the LS Graph. In fact, the x,y coordinates of this graph are completely irrelevant, and are only arranged as below for a compact visualization.

![](http://i.imgur.com/atHJTg2.png "Nodes")
*Figure 2 - Graph representation of the online writing process*

TypeShift attempts to synthesize the best aspects of the visualization techniques mentioned above. It captures both the temporal rate of language production, and highlights the discrete nature of word tokens.

#### Methodology
The typing data was collected from 486 Louisiana Tech students. The participants reported themselves to be 41.3% female, 56.4% male and 88.3% right-handed and 9.1% left-handed. (These do not sum to 100%; on each question some percentage of participants chose not to respond to one or more of the demographic questions.) 

##### Data Collection

The participants were seated at a Dell desktop with a QWERTY keyboard and presented with a series of prompts in Standard American English. The participant was required to type at least 300 characters in response to each prompt, at which time the participant was presented with a button allowing him or her to proceed to the next prompt. Each participant responded to 10-12 prompts. Prompts were presented in random orders, though there was an equal distribution of tasks for each level of cognitive effort. The average response contains 921 keystrokes; the final response contained an average of 448 characters and 87 words. A keylogger with 15.625 milliseconds clock resolution was used to record text and keystroke event timestamps (Locklear et al., 2014). 

Each prompt was drawn from one of six tasks: Remember, Understand, Apply, Analyze, Evaluate or Create. This task type was determined by the experimenters, who assessed the cognitive demands of each question as they related to Bloom’s Taxonomy (Anderson, Krathwohl, and Bloom, 2001). Bloom’s Taxonomy assigns a level from 1-6 to these cognitive tasks. 

It should be noted that the cognitive effort measure of a prompt is most accurately interpreted as the expected cognitive demands as hypothesized by Bloom’s Taxonomy. It is possible or even likely that some participants may experience different cognitive loads than would be expected by a given prompt. For example, a participant may choose to create new knowledge (e.g., making up his or her favorite movie), rather than retrieve a memory in responding to a Remember prompt. Additionally, a participant may have experiences that are relevant to a Create prompt (e.g., having written a film script); this may lead to a response which is based more on recall than creative thought. 

##### Preprocessing

The stream of typing data was clustered into word tokens using the Stanford CoreNLP (Manning et al., 2014) parser. Each word token was annotated with its part of speech and semantic role. The semantic role is of interest because psychologists such as James Pennebaker (Chung & Pennebaker, 2007) posit that function words, e.g. you, the, it or them, are particularly psychologically informative. This is in contrast to the traditional view that content words, e.g. red, fast, smack or mug, contain the most amount of cognitive information. In addition, the start time and end time of each token was recorded, along with the keystrokes that comprise each token.

In order to allow for typing sessions of different time lengths to be compared, the elapsed time of each typing session was normalized and converted to the proportion of a complete session, i.e. 0.0 – 1.0. Similarly, the typing rate for each token (# of keystrokes/token time span) was normalized and converted to a z-score, to allow for comparison across typists. By normalizing the typing rate, a visualization can shed light on not only whether a typist is typing rapidly overall, but also rapidly for himself or herself.

#### TypeShift User Interface

The TypeShift tool was designed using the shiny Web Application Interface for R (Chang, et al. 2016). This allows for rapid prototyping as well as rapid deployment. The tool allows a user to select exactly which typing session to visualize, as well as which aspects of a typing session to include in the visualization.

![](http://i.imgur.com/By5Q9hH.png "UI")
*Figure 3 - Screenshot of the TypeShift User Interface*

The menu on the side provides a number of options:

 - *Selected User* – A list of available typists is presented along with the the typist’s age, gender and native language (L1).
 - *Typing Session* – Within the selected typist, a list of the question prompts he or she responded to is presented.
 - *Parts-of-Speech* – The user can choose to display only certain syntactic categories, such as only nouns or only verbs.
 - *Semantic Units* – The user can choose to display only function or content words.
 - *Trend Lines* – The user can compare this typing session to overall trends:
     - All Typists – The entire dataset
     - All This User’s Answers – Every answer from the selected typist
     - Same Question – All responses to the same typing prompt
     - Same L1 – All typing sessions from users with the same native language

The main plot charts the total number of keystrokes produced versus the proportion of the typing session that was completed. In this way, the slope of the resulting line (series of points) reflects the typing rate: a steeper slope represents a more rapid typing rate. The color and size of a point represent the typing rate of a particular token, in contrast to the overall typing rate. A point’s border thickness represents the number of times a token was revised. In other words, a token with a thick border represents a high number of backspaces or deletes within the token.

Finally, a user can click on a particular token to see a detailed view of that token’s timing. The pause before each character is displayed as a red point for that particular instance, as well as in a box plot for the overall distribution of pauses. In this way, a user can visualize how a typist produces a specific word, relative to other typist’s producing the same word.

#### Illustrative Examples

The advantages of the TypeShift tool can be understood better through example. The examples below highlight how TypeShift can bring to light certain key attributes of a typist or typing session.

![Imgur](http://i.imgur.com/2n0g55I.png)
*Figure 4 – Average typing session for a slow typist*

Figure 4 illustrates the importance of comparing a typing session not only to the overall mean, but to the within-subject mean, as well. Compared to the overall population, this typing session would be considered average. However, for this typist, this particular session is actually very rapidly paced. If a researcher were trying to understand this particular typist, this visualization helps show that this is not a typical typing session for this typist.

![](http://i.imgur.com/pvhBucF.png)
*Figure 5 - Slow but steadily-paced typist, with typing bursts*

Figure 5 illustrates a typist who is slow, but types in bursts at a relatively constant rate. The overall constant rate is illustrated by the uniform slope of the plot, along with similarly sized and colored points. The burstiness of the typing session is illustrated by the large gaps in the plot.

![](http://i.imgur.com/mEUPNOm.png)
*Figure 6 - Inconsistent typing rate*

Figure 6 illustrates a typist with a more inconsistent typing rate. This can be seen by the varying slope of the plot, along with the varying colors and sizes of the tokens. Not only is the typist’s overall rate inconsistent, but he types different tokens at very different rates, as well.

![](http://i.imgur.com/AbHlkAP.png)
*Figure 7 - Heavy revising causes changes in typing dynamics*

Figure 7 is a non-native English speaker, and looks very different than the previous plots. This typist makes a number of large revisions. After the revision, there is often a pause or a change in typing rate.

![](http://i.imgur.com/NuFL0fn.png)
*Figure 8 - Typist starts steadily, then after revisions slows down and pauses*

Figure 8 is also a non-native English speaker. The plot illustrates how the typist starts out at a constant rate. However, after a few revisions in close succession, the typing rate changes and the typist exhibits protracted pauses.

![](http://i.imgur.com/KfqA5mO.png)
*Figure 9 - Faster than average typists that stays consistent*

Figure 9 is a faster-than-average typist, as illustrated by the steeper slope of the user trend line (orange), as compared to the overall trend line (red). Further, this particular session is fast-paced, even for this typist. Unlike Figure 4, where revisions are a catalyst for a change in typing rate, this more proficient typist is not as affected by revising. Rather, the typist maintains a steady rate, despite frequent revisions.

In addition to comparing typing rates, being able to filter for only certain types of word tokens may also shed light on interesting trends and differences. These distinctions could be informative for linguists, psycholinguists and cognitive scientists.

![](http://i.imgur.com/FSxedFn.png)           | ![](http://i.imgur.com/4eJCAZs.png) 
:-------------------------:|:-------------------------:
*Figure 10a – Verbs only*|*Figure 10b – Nouns only*

As can be seen in Figures 10a and 10b, this user types verbs at a faster rate than she types nouns. This could point to the importance of taking into consideration latent linguistic structure when analyzing a typist’s performance. By being able to filter, a user of TypeShift can perform a more direct comparison.

Similarly, Figures 11a and 11b below demonstrate how differently a user types function words versus content words. A comparison of these visualizations seems to point to distinct cognitive processes driving the production of different types of words.

![](http://i.imgur.com/MvP8Dy5.png)| ![](http://i.imgur.com/rqWQcxH.png) 
:-------------------------:|:-------------------------:
*Figure 11a – Function words only*|*Figure 11b – Content words only*

Finally, a user of TypeShift can zoom into a particular word token. The red scatterplot represents the selected typist’s pauses, while the boxplots represent the overall population distribution of pauses. In Figure 12, the subject is a native Russian speaker. As can be seen, the pause before the initial character is more protracted, although the subsequent pauses are very near the population medians. Perhaps this typist had difficultly initially selecting and retrieving the word. However, once the word was retrieved from memory, it could be produced at an average rate.

![](http://i.imgur.com/KdCyRSr.png)
*Figure 12 - Pre-character pauses for each keystroke in the token "these"*

#### Conclusion

The TypeShift user interface aims to provide a dynamic tool to visualize both the continuous and discrete nature of the language production process. Language production is both a stream of flowing words, as well as a series of separate word tokens. By allowing a user to capture both the holistic process as a single linear progression, as well as highlighting individual characteristics of each particular token, the tool can help a user understand both aspects. 

Further, it is often difficult and counterproductive to attempt to use a single metric to label a typing session, e.g. fast or slow. By providing comparisons between typing sessions, TypeShift can shed light on where a typing sessions ranks, both within and across subjects.

Ultimately, the goal of understanding language production is to understand how the mind categorizes and processes information. By allowing a user to better visualize and compare typing sessions, hopefully more rapid progress can be made towards conceptualizing information transmission.

#### Acknowledgements

TO DO!!!

#### Bibliography

Ali, M.L., Monaco, J.V., Qiu, M., & Tappert, C.C.. (2015). Authentication and Identification Methods Used in Keystroke Biometric Systems. HPCC.

Anderson, Lorin W, David R Krathwohl, and Benjamin Samuel Bloom (2001). A taxonomy for learn- ing, teaching, and assessing: A revision of Bloom’s taxonomy of educational objectives. Allyn & Bacon.

Becotte, H-S, Caporossi, G., Hertz, A., and Leblay, C. (in press) Writing and rewriting: Keystroke logging’s colored numerical visualization https://www.gerad.ca/~alainh/HeleneSarah.pdf

Caporossi, G., & Leblay, C. (2011). Online writing data representation: a graph theory approach (pp. 80-89). Springer Berlin Heidelberg.

Chang, W., Cheng, J., Allaire, J., Xie, Y., & McPherson, J. (2016). Shiny: web application framework for R. R package version 0.13.2. https://CRAN.R-project.org/package=shiny

Chung, C., & Pennebaker, J. W. (2007). The psychological functions of function words. Social communication, 343-359.

Erman, B. (2007). Cognitive processes as evidence of the idiom principle.International Journal of Corpus Linguistics, 12(1), 25-53.

Epp, C., Lippold, M., & Mandryk, R.L.. (2011). Identifying emotional states using keystroke dynamics. CHI.

Lindgren, E., & Sullivan, K. P. (2002). The LS graph: A methodology for visualizing writing revision. Language Learning, 52(3), 565-595.

Locklear, H., Govindarajan, S., Sitova, Z., Goodkind, A., Brizan, D. G., Rosenberg, A., ... & Balagani, K. S. (2014, September). Continuous authentication with cognition-centric text production and revision features. InBiometrics (IJCB), 2014 IEEE International Joint Conference on (pp. 1-8). IEEE.

Manning, C. D., Surdeanu, M., Bauer, J., Finkel, J. R., Bethard, S., & McClosky, D. (2014, June). The Stanford CoreNLP Natural Language Processing Toolkit. In ACL (System Demonstrations) (pp. 55-60).

Moskovitch, R., Feher, C., Messerman, A., Kirschnick, N., Mustafić, T., Camtepe, A., ... & Elovici, Y. (2009, June). Identity theft, computers and behavioral biometrics. In Intelligence and Security Informatics, 2009. ISI'09. IEEE International Conference on (pp. 155-160). IEEE.

Rumelhart, D., & Norman, D. (1982). Simulating a skilled typist: A study of skilled cognitive-motor performance. Cognitive Science, 6(1), 1-36. doi:10.1016/s0364-0213(82)80004-9 

Schilperoord, J. (1996). It's about time: Temporal aspects of cognitive processes in text production (Vol. 6). Rodopi.

Serwadda, A., Wang, Z., Koch, P., Govindarajan, S., Pokala, R., Goodkind, A., . . . Balagani, K. (2013). Scan-Based Evaluation of Continuous Keystroke Authentication Systems. IT Professional IT Prof., 15(4), 20-23. 

Shneiderman, B. (1996, September). The eyes have it: A task by data type taxonomy for information visualizations. In Visual Languages, 1996. Proceedings., IEEE Symposium on (pp. 336-343). IEEE.
