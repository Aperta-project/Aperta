# Fig setup for Tahi

The tahi repository contains a fig/docker configuration for setting up
a running tahi (plus ihat) with minimal effort.

## Installing

This fig setup is configured to pass in all deploy-specific
information via environment variables. The relevant environment
variables are:

- s3 configuration
    - `AWS_ACCESS_KEY_ID`
    - `AWS_REGION`
    - `AWS_SECRET_ACCESS_KEY`
    - `S3_BUCKET`
    - `S3_URL`

- CAS authentication
    - `CAS_HOST`
    - `CAS_LOGIN_URL`
    - `CAS_DISABLE_SSL_VERIFICATION`
    - `CAS_PORT`
    - `CAS_SERVICE_VALIDATE_URL`
    - `CAS_SSL`

- misc
    - `DEFAULT_MAILER_URL`
    - `FROM_EMAIL`
    - `RAILS_ENV`
    - `RAILS_SECRET_TOKEN`
    - `MAILSAFE_REPLACEMENT_ADDRESS`
    - `OXGARAGE_URL`
    - `SEGMENT_IO_WRITE_KEY`
    - `SENDGRID_PASSWORD`
    - `SENDGRID_USERNAME`

First, create an `.env` file with a skeleton config:

```
cp .env.fig.example .env
```

And change foreman to use ``Procfile.fig`` by editing the ``.foreman``
file:

```
port: 5000
procfile: Procfile.fig
```

### S3 Configuration

In order to use S3 storage, you will need an S3 bucket. You should use
a random UUID for the bucket name. You can easily generate these
online. When you have a bucket name, set the `S3_BUCKET` variable in
your `.env` file:

````
S3_BUCKET=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```

If you used a different region thatn `us-west-1` set `AWS_REGION`.

You will need to setup a new user on IAM. Note the access and secret
key and set them accordingly in your `.env` file:

```
AWS_ACCESS_KEY_ID=YYY
AWS_SECRET_ACCESS_KEY=XXX
```

Also note down the "User ARN", e.g.
`arn:aws:iam::123456789012:user/tahi-test`. You will need this to
configure the bucket permissions properly. Edit your bucket's
permissions policies as follows, taking care to replace the ARN and
bucket name:

```
{
   "Version" : "2012-10-17",
   "Statement" : [
      {
         "Principal" : {
            "AWS" : "arn:aws:iam::123456789012:user/tahi-test"
         },
         "Action" : [
            "s3:PutBucketCors",
            "s3:ListBucket"
         ],
         "Effect" : "Allow",
         "Resource" : "arn:aws:s3:::XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
         "Sid" : ""
      },
      {
         "Sid" : "",
         "Principal" : {
            "AWS" : "arn:aws:iam::123456789012:user/tahi-test"
         },
         "Action" : [
            "s3:AbortMultipartUpload",
            "s3:GetObjectAcl",
            "s3:RestoreObject",
            "s3:GetObjectVersion",
            "s3:DeleteObject",
            "s3:DeleteObjectVersion",
            "s3:GetObject",
            "s3:PutObjectAcl",
            "s3:PutObjectVersionAcl",
            "s3:ListMultipartUploadParts",
            "s3:PutObject",
            "s3:GetObjectVersionAcl"
         ],
         "Effect" : "Allow",
         "Resource" : "arn:aws:s3:::XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/*"
      }
   ]
}
```

You will also need to set the CORS configuration for the bucket as
follows:

```
<?xml version="1.0" encoding="UTF-8"?>
<CORSConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <CORSRule>
        <AllowedOrigin>*</AllowedOrigin>
        <AllowedMethod>PUT</AllowedMethod>
        <AllowedMethod>POST</AllowedMethod>
        <MaxAgeSeconds>3000</MaxAgeSeconds>
        <AllowedHeader>*</AllowedHeader>
    </CORSRule>
</CORSConfiguration>
```

### Rails setup

Now we need to set things up a bit. Install your dependencies:

```
bundle install
```

You will next need to generate a rails secret. You can do this by
running:

```
foreman run bundle exec rake secret
```

Use this value to set the `RAILS_SECRET_TOKEN` variable in your `.env`
file.

### Docker setup

You are now ready to build! Run:

```
foreman run -- sudo -E fig -f fig.dev.yml build
```

(possibly you do not need sudo: it seems to be necessary on Ubuntu).

And run it:

```
foreman run -- sudo -E fig -f fig.dev.yml up
```

In another terminal, set up the database:

```
foreman run bundle exec rake db:migrate
```

We need to create a solr collection:

```
curl -s "http://localhost:53013/solr/admin/cores?action=CREATE&name=development&instanceDir=tahi&config=solrconfig.xml&schema=schema.xml&dataDir=data"
```

and seed the database:

```
foreman run bundle exec rake db:seed
```

In order to get ihat (document conversion) working, you will need to generate an API key. 
```
foreman run bundle exec rake api:generate_access_token
```

Note down the key and set `TAHI_TOKEN` in your `.env` file.

Now you need to initialize solr again (why?)

```
curl -s "http://localhost:53013/solr/admin/cores?action=CREATE&name=development&instanceDir=tahi&config=solrconfig.xml&schema=schema.xml&dataDir=data"
```

Finally:

```
foreman start
```

Now you should be able to navigate to:

  <http://localhost:5000/>

and login to tahi. (There is an admin user with the username
`mikedoel` and password `skyline1` already created.)
