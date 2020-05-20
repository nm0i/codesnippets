## Read paypal report

read.paypal <- function(...) {
    tmptable <- read.csv(...);
    tmptable$Amount <- gsub(",", "", tmptable$Amount);
    tmptable$Balance <- gsub(",", "", tmptable$Balance);
    tmptable;
}
