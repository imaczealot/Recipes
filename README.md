# Recipes
Fetch Mobile Take Home Project

### Steps to Run the App
From Xcode select the Recipes target and then select the Run command
The app is a single view application displaying a Table of recipes.
The user can refresh the view by pulling dowin on the table - implementing UIRefreshControl
 
### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
My intent was to implement the requirements in the simplest way I know.
This is a UIKit app using the techniques and shared libraries I've used in the past.
With the exception of Kingfisher, this is the first time I've used this third party library.


### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?
I spent a good 6 hours on Saturday getting the base functionality of the app working.  I tried to use Core Data for the first time and spent two hours unsuccessfully.  Ended up reverting that work and just using Kingfisher for image caching.
I spent an additional 2 hours on Sunday implementing some example unit tests for the RecipeViewModel.

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
I had using AlamoFire for networking which also provides support for caching network downloaded images. But I decided to go with URLRequests and cache images to a local database instead.  Initially, I was going to using SQLite as I have used SQLite in the past because it's common on Android and iOS.  I have used it to specifically cache draft messages including saving images into blobs and would have been fairly straight forward to reusing old work.  However, I tried to use Core Data for the first time as it was an option presented by Xcode when creating a new project.  This was not a good decision on my part.  I resorted to using Kingfisher instead so that I could spent my remaining time creating some example unit tests.

### Weakest Part of the Project: What do you think is the weakest part of your project?
UI Design.  The custom TableViewCell is very basic.

### External Code and Dependencies: Did you use any external code, libraries, or dependencies?
I used the following third party libraries:
DZNEmptyDataSet - provides a nice mechanism and UI when Table View is empty or there is a loading issue.
Kingfisher - used for the first time to cache images
SVProgressHUD - provides a nice activity indictor UI
OHHTTPStubs - provides unit test support for mocking network calls.

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
I read the instructions late Friday night and felt overly confident I had a plan for Saturday morning.
However, I was caught off guard the Xcode didn't have the old Master-Detail application template anymore.  Took me a bit to remember how to make a UITableViewController from scratch.

