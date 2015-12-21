# Tingun #

Tungun downloads any one of your Mailgun mailing lists as a CSV file.

# Requirements #

mailgun-ruby

```
gem install mailgun-ruby
```

# Usage #

1. Add your mailgun_api_key to tingun.rb
2. Run from command line, passing the name of the mailing list you'd like to download

```
./tingun.rb mailing_list_alias_address
```