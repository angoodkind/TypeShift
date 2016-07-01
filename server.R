library(ggplot2)
library(dplyr)
library(shiny)
library(RColorBrewer)

shinyServer(function(input, output, session) {
  # collpase/expand instructions
  observeEvent(input$p1Button, ({
    updateCollapse(session, "instructionsOutput",
                   open="Instructions",
                   close="Instructions")  
  })
  )
  
  # filter question options based on userID
  output$answerOutput <- renderUI({
    df.u <- filteredForUser()
    if(!is.null(df)) {
      selectInput("answerInput", "Select A Typing Session",
                  sort(unique(df.u$QuestionText)))
    }
  })
  
  # filter df based on userID
  filteredForUser <- reactive({
    df %>%
      filter(
        Demog.Info == input$userInput
      )
  })
  
  # filter df based on all UI options
  filteredFull <- reactive({
    if (is.null(input$answerInput)) {return(NULL)}
    df %>% 
      filter(
        Demog.Info == input$userInput,
        QuestionText == input$answerInput,
        Category %in% input$posInput,
        Semantics %in% input$semanticInput
      )
  })
  
  # filter df based on only user and answer
  filteredForUserAnswer <- reactive({
    if (is.null(input$answerInput)) {return(NULL)}
    df %>% 
      filter(
        Demog.Info == input$userInput,
        QuestionText == input$answerInput
      )
  })
  
  # filter df based on selected user's native English
  filteredForL1 <- reactive({
    df %>%
      filter(
        NativeEnglish == df.userInfo[
          df.userInfo$Demog.Info==input$userInput,'NativeEnglish']
      )
  })
  
  # filter df based on selected question, but for all users
  filteredForQuestion <- reactive({
    df %>%
      filter(
        QuestionText == input$answerInput
      )
  })
  
  # filter df based on selected question's cognitive load
  filteredForCogLoad <- reactive({
    df %>%
      filter(
        Cog_load == df.questionInfo[
          df.questionInfo$QuestionText==input$answerInput,'Cog_load']
      )
  })
  
  # output main plot of user's typing session
  output$mainPlot <- renderPlotly({
    if (is.null(filteredFull())) {return()}
    selectedUserID <- df.userInfo[df.userInfo$Demog.Info==input$userInput, 'UserID']
    selectedQuestionID <- df.questionInfo[df.questionInfo$QuestionText==input$answerInput, 'QuestionID']
    m <- list(sizeref=20, sizemode='area',
              cmin=0, cmax=0.25,
              # outline weight based on number of revisions
              line=list(color="black",
                        width=(filteredFull()$RevisCount)*4
                        ),
              colorbar = list(title = "Intra-Token<br>Typing Rate",
                              showticklabels=F,
                              thickness=20,
                              len=0.5,
                              yanchor="bottom"))
    p <- plot_ly(name="Word Token",filteredFull(), 
                 x=Relative.Time.Progress, y=cumul.ans.keystroke,
                 mode='markers', color=KeystrokeRate.Z, size=KeystrokeRate.Z*3400,
                 marker=m, colors='BuGn', 
                 source="main", 
                 hoverinfo='text', text=paste("token: ",Token, "Keystrokes: ",
                                              KeystrokeCount),
                 colorbar = list(title = "Typing Rate")) %>%
      layout(
        title= paste0("Word Tokens for User ",
                     selectedUserID, ", Question ", selectedQuestionID),
        xaxis= list(title="Proportion Complete",range=c(0,1)),
        yaxis= list(title="Total Keystrokes",range=c(0,max(filteredForUserAnswer()$cumul.ans.keystroke))),
        legend= list(
          y = 0.15,
          x = 1.0
        )
      )
    
    # add trend line for all users
    if ("allTypists" %in% input$trendsInput) {
      lm.all <- lm(cumul.ans.keystroke ~ Relative.Time.Progress,
                   data=df)
      p <- add_trace(data=df,p, y=fitted(lm.all), x=Relative.Time.Progress,
                     mode='lines', name="All Users",
                     line=list(
                       color='red'
                     )) %>%
        layout(
          xaxis=list(range = c(0,1)),
          showlegend=T
        )
    }
    
    # add trend line for selected user's mean timing
    if ("allThisUser" %in% input$trendsInput) {
      lm.user <- lm(cumul.ans.keystroke ~ Relative.Time.Progress,
                    data=filteredForUser())
      p <- add_trace(data=filteredForUser(), p, y=fitted(lm.user), x=Relative.Time.Progress,
                     mode='lines', name=paste0("User ", selectedUserID),
                     line=list(
                       color='orange'
                     )) %>%
        layout(
          xaxis= list(range = c(0,1)),
          showlegend=T          
        )
    }
    
    # add trend line for all user's answering selected question
    if ("allQuestion" %in% input$trendsInput) {
      lm.question <- lm(cumul.ans.keystroke ~ Relative.Time.Progress,
                        data=filteredForQuestion())
      p <- add_trace(data=filteredForQuestion(),p, y=fitted(lm.question), x=Relative.Time.Progress,
                     mode='lines', name="Question",
                     line=list(
                       color='green'
                     )) %>%
        layout(
          xaxis= list(range = c(0,1)),
          showlegend=T
        )
    }
    
    # add trend line for same L1 as selected user
    if ("allL1" %in% input$trendsInput) {
      lm.l1 <- lm(cumul.ans.keystroke ~ Relative.Time.Progress,
                  data=filteredForL1())
      p <- add_trace(data=filteredForL1(),p, y=fitted(lm.l1), x=Relative.Time.Progress,
                     mode='lines', name="L1",
                     line=list(
                       color='blue'
                     )) %>%
        layout(
          xaxis= list(range = c(0,1)),
          showlegend=T
        )
    }
    
    # add trend line for all user's answering questions where the
    # cognitive load is the same as the selected question
    if ("allCogLoad" %in% input$trendsInput) {
      lm.cogload <- lm(cumul.ans.keystroke ~ Relative.Time.Progress,
                       data=filteredForCogLoad())
      p <- add_trace(data=filteredForCogLoad(),p, y=fitted(lm.cogload), x=Relative.Time.Progress,
                     mode='lines', name="Cog Load",
                     line=list(
                       color='violet'
                     )) %>%
        layout(
          xaxis= list(range = c(0,1)),
          showlegend=T
        )
    }
    p
  })
 
  # if a token is clicked, add a plot of its detailss 
  output$hoverPlot <- renderPlot({
    eventdat <- event_data('plotly_click', source="main") # get event data from source main
    if(is.null(eventdat) == T) return(NULL)        # If NULL dont do anything
    
    # get x-coordinate of click event
    clicked.x <- as.numeric(eventdat[['x']])
    # find matching row by finding same elapsed time point
    token.row <- filteredFull()[
      round(filteredFull()$Relative.Time.Progress,4) == round(clicked.x,4), ]
    clicked.token <- token.row[1,'Token']
    
    # format list of all times for the clicked token
    token.times.str <- strsplit(as.character(token.row[1,'VizKSTimes']), ',')[[1]]
    token.times.unlist <- unlist(token.times.str)
    token.times.vector <- as.vector(as.numeric(token.times.unlist))
    
    # make plot
    createTokenPlot(clicked.token, token.times.vector)
  })
})

# create overall boxplot and scatter plot for selected user
createTokenPlot <- function(token, token.vector) {
  if (is.na(token)) {return(NULL)}
  char.list <- strsplit(token,split='')[[1]]
  
  # get all users times for the clicked token
  df.token <- subset(df, df$Token==token & df$KeystrokeCount==length(char.list), 
                     select=c(VizKSTimes))
  df.token.cols <- separate(df.token, col=VizKSTimes, into=char.list, sep=',')
  df.token.cols <- sapply(df.token.cols, as.numeric)
  df.token.m <- melt(df.token.cols)
  df.scatter <- data.frame('x'=(1:length(token.vector)), 'y'=token.vector)
  
  # if clicked token has multiple instances, create box plots and scatter plot
  if ("X1" %in% colnames(df.token.m)) {
    g <- df.token.m %>% 
      mutate(
        i1 = as.character(cumsum(X1==1))
      ) %>%
      ggplot(., aes(x=i1, y= value))+
      geom_boxplot(outlier.shape=NA) + 
      scale_x_discrete(breaks= (1:length(char.list)), 
                       labels= char.list)+
      xlab(NULL)
    g + geom_point(data=df.scatter, aes(x=x,y=y), size=5, colour='red') +
      ggtitle(paste("Overall Pause Distributions and Selected User Pauses For ",
                    "\"",token,"\"",sep="")) +
      xlab("Characters") + ylab("Pause Preceding Character") +
      theme(axis.text.x=element_text(size=15))
  
  # if token is a singleton, only create scatter plot
  } else {
    df.single.token <- as.data.frame(list('chars'=char.list,
                                          'times'=df.token.m[['value']]))
    ggplot(data=df.single.token, aes(x=1:length(char.list), y=times)) +
      geom_point(size=5, colour='red')+
      scale_x_continuous(breaks=1:length(char.list), labels=char.list) +
      ggtitle(paste("Selected User Pauses For ","\"",token,"\"",sep="")) +
      xlab("Characters") + ylab("Pause Preceding Character") +
      theme(axis.text.x=element_text(size=15))
  }
}