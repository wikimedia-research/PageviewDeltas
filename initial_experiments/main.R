library(pageviews) # the client library for the new pageviews API. https://github.com/Ironholds/pageviews
library(lubridate) # timestamp messing

# Unwanted page titles; things that are patently bollocks or automata, or just not content.
unwanted_pages <- c("Special:Search","Special:Book", "User:GoogleAnalitycsRoman/google-api",
                    "Special:MobileMenu", "Special:Watchlist", "Special:CiteThisPage",
                    "Special:RecentChanges","Help:IPA_for_English", "Template:GeoTemplate",
                    "Special:RecentChangesLinked","Special:Statistics")

# Format the individual dates
dates <- as.character(lubridate::day(seq(as.Date("2015-11-01"), as.Date("2015-11-30"), "day")))
dates <- ifelse(nchar(dates) == 1, paste0("0",dates), dates)

# Little function for handling the retrieval
get_pageviews <- function(day, access){
  data <- top_articles(platform = access, month = "11", day = day)
  data <- data[!data$article %in% unwanted_pages,]
  cat(".")
  return(data)
}


# Get by-day data for desktop, format, exclude unwanted pages, and bind it together at the end. Ditto
# mobile web and mobile app.
results <- lapply(c("desktop", "mobile-web", "mobile-app"),
                  function(x){
                    return(do.call("rbind", lapply(dates, get_pageviews, access = x)))
                  })

# Tie it all together and export
results <- do.call("rbind", results)
write.table(results, file = "initial_enwiki_data.tsv", quote = TRUE, sep = "\t", row.names = FALSE)
