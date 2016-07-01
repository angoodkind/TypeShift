library(shiny)
library(plotly)
library(shinythemes)
library(shinyBS)

trendLineOptions = c("All Typists"="allTypists", 
                     "All This User's Answers"="allThisUser", 
                     "Same Question"="allQuestion", 
                     "Same L1"="allL1", 
                     "Same Cognitive Load"="allCogLoad"
)

shinyUI(fluidPage(theme=shinytheme('spacelab'),
  
  # Application title
  titlePanel("Visualizing and Comparing Typing Output", windowTitle = "TypeShift"),


fluidRow(
  # collapsable instruction panel
  column(12,
         bsCollapse(id="instructionsOutput", open="instructionsPanel",
                    bsCollapsePanel("Instructions",
          HTML("
<p><strong>Main Plot</strong></p>
<ul style='list-style-type: circle;'>
<li>Select a User, and then a question prompt that the selected user<br /> has answered</li>
<li>Each token appears as a single point, with the token size and color reflecting<br /> the overall typing rate of that token
<ul>
<li>The x-axis is a normalized timeline, represented as proportion of the session 
    completed</li>
<li>The y-axis is cumulative keystrokes. Rapid typing will result in a steeper
    slope</li>
<li>The color and size of a point reflect the typing rate of that token</li>
<li>A token's border represents the number of revisions in that token. A thick
      border means the token was revised a number of times.</li>
</ul>
</li>
<li>Select which parts-of-speech tokens to display</li>
<li>Select which semantic unit tokens to display</li>
<li>Select which trend lines to compare the selected answer to</li>
</ul>
<p><strong>Hover Plot</strong></p>
<ul style='list-style-type: circle;'>
<li>Click a token for detailed timing information.
<ul>
<li>A box plot of every user's timing for that token will be displayed, along with a scatter <br /> plot for that individual user.</li>
<li>If the token is a singleton, only the&nbsp;scatter plot will be displayed.</li>
</ul>
</li>
</ul>
<p><strong>Acknowledgements</strong></p>
All keystroke data was collected at Louisiana Tech University (LTU), in accordance
with LTU's IRB. In particular, Dr. Vir Proha, Dr. Kiran Balagani, and Dr. Mike O'Neal
provided substantial contributions and data sanitizing. This work was supported in part 
by DARPA Active Authentication grants FA8750-12-2-0201 and FA8750-13-2-0274. The views, 
findings, recommendations, and conclusions contained herein are those of the authors 
and should not be interpreted as necessarily representing the official policies or 
endorsements, either expressed or implied, of the sponsoring agencies or the U.S. Government.

        ")
      )
    )
  ),
  # action button to collapse instruction panel
  column(12, offset=4,
         actionButton("p1Button", "Expand/Collapse Instructions"),
         br(), br()
        ),
  
  # Sidebar
  sidebarLayout(
    sidebarPanel(
      tags$h4("Typing Session"),
      # select user
      selectInput("userInput","Select User", sort(unique(df$Demog.Info)),
                  selected = sort(unique(df$Demog.Info))[1]),
      # select question (list filtered by selected user)
      uiOutput("answerOutput"),
      tags$h4("Linguistic Elements"),
      # choose which POS's to display
      checkboxGroupInput("posInput", "Select Parts of Speech",
                         choices=c('Noun','Verb','Modifier','Other'),
                         selected=c('Noun','Verb','Modifier','Other')),
      # choose which semantic units to display
      checkboxGroupInput("semanticInput", "Select Semantic Units",
                         choices=c("Content Words"="Content","Function Words"="Function"),
                         selected=c("Content", "Function")),
      # choose which trend lines to add
      checkboxGroupInput("trendsInput", tags$h4("Add Trend Lines"),
                         choices=trendLineOptions,
                         selected="allTypists"),

      # allows for long question texts to not be wrapped
      tags$head(
        tags$style(HTML('
                        .selectize-input {
                        white-space: nowrap;
                        }
                        #answerInput + div>.selectize-dropdown{
                        width: 660px !important;
                        }
                        #userInput + div>.selectize-dropdown{
                        width: 330px !important;
                        }
                        '
        )
        )
        )
    ),
    
    mainPanel(
      # Show a plot of the generated distribution
      plotlyOutput("mainPlot"),
      br(),
      # pop-up plot if token is clicked
      plotOutput("hoverPlot",width="90%",height="200px")
    )
  )
)))
