#' @docType class
#' @title MonthLabelFormatter
#' @description Generates compact, unambiguous single-letter month axis labels
#' using Unicode superscript characters to disambiguate months that share the
#' same first letter (J=Jan/Jun/Jul, M=Mar/May, A=Apr/Aug).
#'
#' Result: J\u00b9 F M\u00b9 A\u00b9 M\u00b2 J\u00b2 J\u00b3 A\u00b2 S O N D
#'
#' @importFrom R6 R6Class
#' @export
#' @examples
#' \dontrun{
#' label <- MonthLabelFormatter$public_methods$Format(1)  # "J\u00b9"
#' all   <- MonthLabelFormatter$public_methods$AllLabels() # list of 12 labels
#' }

MonthLabelFormatter <- R6::R6Class(
  "MonthLabelFormatter",
  public = list(
    #' @description Returns a compact axis label for the given month number (1-12).
    #' @param monthNumber Month number, 1 = January through 12 = December.
    #' @return A single-letter label, with a Unicode superscript suffix for
    #'         months whose first letter is shared by another month.
    Format = function(monthNumber) {
      if (!is.numeric(monthNumber) || length(monthNumber) != 1 ||
          monthNumber < 1 || monthNumber > 12 || monthNumber != as.integer(monthNumber)) {
        stop("monthNumber must be an integer between 1 and 12")
      }

      letters <- c("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D")

      # Unicode superscripts: \u00b9 = 1, \u00b2 = 2, \u00b3 = 3
      superscripts <- c(
        "\u00b9",   # 1  Jan  -> J\u00b9
        "",         # 2  Feb  -> F
        "\u00b9",   # 3  Mar  -> M\u00b9
        "\u00b9",   # 4  Apr  -> A\u00b9
        "\u00b2",   # 5  May  -> M\u00b2
        "\u00b2",   # 6  Jun  -> J\u00b2
        "\u00b3",   # 7  Jul  -> J\u00b3
        "\u00b2",   # 8  Aug  -> A\u00b2
        "",         # 9  Sep  -> S
        "",         # 10 Oct  -> O
        "",         # 11 Nov  -> N
        ""          # 12 Dec  -> D
      )

      return(paste0(letters[monthNumber], superscripts[monthNumber]))
    },

    #' @description Returns a list of 12 formatted month labels,
    #' index 1 = January through index 12 = December.
    #' @return Character vector of 12 strings.
    AllLabels = function() {
      sapply(1:12, function(m) self$Format(m), USE.NAMES = FALSE)
    }
  )
)
