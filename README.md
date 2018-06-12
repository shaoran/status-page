# status-page

## Project plan

### Research

1. I'll research the status pages of the 4 sites mentioned in the PDF. My first question is
*Is there some kind of API that I can use to get the data I'm looking for?*
2. Second question: *are there any similarities between the sites?*

 After a quick look I realized that 3 of the 4 sites use the [same engine][1] and there is a JSON URL that
can be called to get the information. That means that I can write a "parser" for all sites that use
[statuspage][1] as engine.

3. I'll take a look at the *Thor* `gem` that allows easy creation of command line interfaces. I have written
command line interfaces in other languages (C & python), so using this `gem` won't be a problem.


### Code

As stated in the PDF, I'm submitting the project plan before writing any code. My general plan will be:

- create a new `gem`
- write classes/modules that are going to fetch the data and parse it
- write `rspec` tests that test the code
- write a class/module that stores the information
- build the ruby file that glues together all the components to create the CLI

## Time table

| Task   | Time expected | Time needed |
|--------|---------------|-------------|
| **Common research** | 2 hours | - |
| **Writing a first version** | 4-5 hours | - |
| **Testing, debugging, polishing code** | 1-2 hour | - |


[1]: https://www.statuspage.io
