# Game of Thrones - Character Deaths

# This analysis uses the character-deaths.csv file that was imported into a local MySQL database.

#  https://www.kaggle.com/mylesoneill/game-of-thrones

# --------- INSTALL NECESSARY PACKAGES ---------------------

# May need to run R as an administrator

# install.packages(c("RMySQL", "dplyr", "ggplot2", "reshape2"))
library(RMySQL)
library(dplyr)
library(ggplot2)
library(reshape2)

# --------- CONNECT TO DATABASE ----------------------------

mydb <-dbConnect(MySQL(), user='r-user', password='password', dbname='game_of_thrones', host='localhost')

dbListTables(mydb)

q <- dbSendQuery(mydb, "select * from character_deaths")
ds.raw <- fetch(q, n=-1)

# --------- PROCESSING ------------------------------------

ds.stg <- ds.raw
colnames(ds.stg) <- c("name","allegiances","deathYear","bookOfDeath","deathChapter","bookIntroChapter","gender","nobility","GoT","CoK","SoS","FfC","DwD")

ds.died <- filter(ds.stg, bookOfDeath %in% c(1, 2, 3, 4, 5))

deaths.book <- group_by(ds.died, bookOfDeath) %>% summarize(count = n())

b <- ggplot(deaths.book, aes(bookOfDeath, count, fill=bookOfDeath)) + geom_bar(stat="identity") + labs(title="Character Deaths by Book", x="Book", y="Number of Deaths") + theme(legend.position="none") + geom_text(aes(label=count), vjust=-.5)

deaths.house <- group_by(ds.died, allegiances)

# --------- DEATHS BY HOUSE -------------------------------

q2 <- dbSendQuery(mydb, "select *, trim(replace(Allegiances, 'House ', '')) as house from character_deaths")
ds.raw <- fetch(q2, n=-1)

ds.stg <- ds.raw
colnames(ds.stg) <- c("name","allegiances","deathYear","bookOfDeath","deathChapter","bookIntroChapter","gender","nobility","GoT","CoK","SoS","FfC","DwD","house")

ds.died <- filter(ds.stg, bookOfDeath %in% c(1, 2, 3, 4, 5))

ds.house <- filter(ds.died, !house %in% c("None", "Night's Watch", "Wildling"))

deaths.house <- group_by(ds.house, house) %>% summarize(Noblemen = sum(nobility==1), Commonfolk = sum(nobility==0))

deaths.house.long <- melt(deaths.house, id.var="house")

h <- ggplot(deaths.house.long, aes(reorder(house, value), value, fill = variable)) + geom_bar(stat="identity") + coord_flip() + labs(title="Character Deaths by House", y="Number of Deaths", x="House") + theme(legend.position="right") + guides(fill=guide_legend(title="Type"))

# --------- DEATHS BY GENDER ------------------------------

q3 <- dbSendQuery(mydb, "select *, case (Gender) when 0 then 'Female' else 'Male' end as gender_2 from character_deaths")
ds.raw <- fetch(q3, n=-1)

ds.stg <- ds.raw
colnames(ds.stg) <- c("name","allegiances","deathYear","bookOfDeath","deathChapter","bookIntroChapter","genderRaw","nobility","GoT","CoK","SoS","FfC","DwD","gender")

ds.died <- filter(ds.stg, bookOfDeath %in% c(1, 2, 3, 4, 5))
deaths.gender <- group_by(ds.died, gender) %>% summarize(count=n())

g <- ggplot(deaths.gender, aes(gender, count, fill=gender)) + geom_bar(stat="identity") + labs(title="Character Deaths by Gender", x="Gender", y="Number of Deaths") + theme(legend.position="none") + geom_text(aes(label=count), vjust=-.5)
