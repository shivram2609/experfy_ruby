# Transformation Service

Transformation service will be used for various data transformation like basic(primitive) type conversion (`string -> integer`, `string -> boolean`, `string -> date` etc) and more complex or custom transformations (JSON payload for example). Also, this service will be used to define various utilities classes which will transform data to our specific needs. Example of that data is phone formatter, where we will from known input like country and number itselft format that phone number to specific format (international dialing for example).

Sepcification page: https://experfy.atlassian.net/wiki/spaces/AR/pages/1536032851/Transformation+Specification

# How to setup and run project locally

```
1. Clone project locally - git clone git@github.com:experfy/transformation.git
2. Swith to branch story/ar-97 who has latest changes
3. Run command bundle install
4. Make sure you have Redis installed and started
5. Start the app with command: bundle exec rackup
6. App is available on http://localhost:9292
```

# How to make request on the app to transform basic(primitive) data type

Make a GET request to `/type-conversion` endpoint in a following way:

![Primitive Types Request](https://github.com/experfy/transformation/blob/story/ar-97/samples/images/Primitive_Types.png?raw=true)  

Required query parameters are: `data`, `to`, `from`. More details on how everything works can be found on the specification page above.

# How to make request on the app to transform custom payload

Note: Here, we are using opportunity sample to generate `dry-transformer` instructions. That instruction file in located in `samples/project_sample.json` file.

Make a POST request to `/custom-transformation` endpoint with BODY params like below:

```
{
    "params": {
        "state": "draft",
        "title": "POC Data Transformations",
        "description": "<p class=\\\"description\\\">dsfdf</p>",
        "responsibilities": "Responsibilities examples",
        "start_date": "2021-05-01",
        "end_date": "2021-05-10",
        "status": "proposed",
        "time_commitment": 40,
        "min_rate": 100,
        "max_rate": 200,
        "project-type": "remote",
        "travel-required": true,
        "travel-requirement": "26-50%",
        "hiring-manager-first-name": "John",
        "hiring-manager-email": "",
        "us-legal-entity": "",
        "deloitte-ppmd": "",
        "deloitte-market-offering": "",
        "skills-attributes": [],
        "tools-attributes": [],
        "questions-attributes": [],
        "relationships": {
            "skills": {
                "data": [
                    {
                        "type": "skills",
                        "id": "279"
                    }
                ]
            },
            "tools": {
                "data": [
                    {
                        "type": "tools",
                        "id": "123"
                    }
                ]
            }
        }
    },
    "type": "project_transformation_schema" 
}
```

Example of POSTMAN request with above payload is added in the image below:

![Custom Transformation Request](https://github.com/experfy/transformation/blob/story/ar-97/samples/images/Custom_Transformation.png?raw=true)

# How to make request on the app to transform phone number

Make a GET request to `/phone` endpoint with the following parameters: `phone`, `country`, `format`.

`phone` is the actual phone number we want to transform. `country` is the country name based on which we will convert that number. `format` is the actual format we want for the output. Currently supported formats are: `default`, `europe`, `us`.

Example of this request using a POSTMAN is in a below image:

![Phone Formatter Request](https://github.com/experfy/transformation/blob/story/ar-97/samples/images/Phone_Formatter.png?raw=true)
