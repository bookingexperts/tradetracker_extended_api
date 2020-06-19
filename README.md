# Tradetracker extended API

For our own needs we needed the Tradetracker API to be more easily accessible and available in different response formats.

To check the third party conversions we make heavy use of spreadsheets.
Now it's possible to use a simple `IMPORTDATA(https://<domain>/click_transactions/csv?customer_id=123&api_key=ABC)` in spreadsheets to get the data.
Or `https://<domain>/click_transactions/json?customer_id=123&api_key=ABC` for json.

## Ruby on Jets

This project makes use of Ruby on Jets to deploy it as a serverless application.
See [https://rubyonjets.com/](https://rubyonjets.com/) for more information.

## How run in development

Install ruby 2.5.X using your favorite tool (`rbenv`, `rvm`, `brew`)

Ensure bundler is installed

    gem install bundler

Run bundle

    bundle install

Start the server

    jets server

Visit [http://localhost:8888/click_transactions/json?customer_id=123&api_key=ABC](http://localhost:8888/click_transactions/csv?customer_id=123&api_key=ABC)

## How to deploy

Run

    jets deploy production

It will use AWS Cloudformation to configure AWS Lambda, AWS API Gateway, AWS S3.
If all is successfull you will be greeted with an AWS API Gateway https endpoint.
