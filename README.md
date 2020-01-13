# EU_ETS
R script and raw data for generating figures in Rea (2019). "The EU emissions trading scheme: protection via commodification?", Culture, Practice & Europeanization 4 (1), 48-73. 

See the paper here: https://www.uni-flensburg.de/fileadmin/content/seminare/soziologie/dokumente/culture-practice-and-europeanization/cpe-vol.4-no.1/seeliger-sommer-cpe-2019-vol.4-nr.1.pdf#page=50

See the journal here: https://www.uni-flensburg.de/soziologie/culture-practice-and-europeanization/

All visualization and analysis completed in R.

Raw auction price data downloaded from: https://sandbag.org.uk/carbon-price-viewer/.

Raw auction revenue data downloaded from: https://www.eex.com/en/market-data/environmental-markets/auction-market/european-emission-allowances-auction/european-emission-allowances-auction-download.

All scripts are built around the following files and file structure. Files included in this repository marked with * . Files created/written by script itself are not listed.

    /your_working_directory
      /EU_ETS_Auctions_Price_and_Revenues
        /EU_ETS_Auctions_Revenues_by_2013_to_Jan2019.csv *
        /EU_ETS_Weekly_price_2008_04_to_2019_01.csv *
      /Figures
        /EU_ETS_EUA_Price2008_04_01_to_2019_01_14.png *
        /EU_ETS_per_auction_and_cum_rev2012_06_01_to_2019_01_20.png *
      /R_Analysis
        /Carbon_Price_and_Auction_Revenue.R *
