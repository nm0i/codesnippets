## Read paypal report

read.paypal <- function(...) {
    tmptable <- read.csv(...);
    tmptable$Amount <- gsub(",", "", A$Amount);
    tmptable;
}
