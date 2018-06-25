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

----

## How to run it

In order to test this project, I recommend to use [RVM][2]. After installing `rvm`:

	$ rvm install ruby-2.5.1
	$ rvm ruby-2.5.1
	$ rvm gemset create status
	$ rvm gemset use status
	$ gem install bundler

These commands install a new ruby version and create a new gemset called `status`.

	$ cd status-page
	$ ./bin/setup         # updates the gemset and runs bundle install
	$ ./bin/status-page   # executes the program


## Time table

| Task   | Time expected | Time needed |
|--------|---------------|-------------|
| **Common research** | 2 hours | 4 hour |
| **Writing a first version** | 4-5 hours | 10 hour |
| **Testing, debugging, polishing code** | 1-2 hour | 2 hours |


In generall I needed more time than I expected. I tend to underestimate the time all the time. Just from reading
the PDF file, I already had a pretty good idea of how I would have solved this problem, the pieces were already
in my head. And I start writing code and I realize afterwards that instead of 30 minutes I needed 2 hour in total.

The *common research* took longer than I expected because even though I'm familiar with Rails, at my company we use
rake tasks over rspec or cucumber, so I had to constantly look up the different rspec matchers (because of the different
workflow I'm used to) and that takes more time than I anticipated.
time that.

I also tend to think to far ahead in the feature, I keep asking myself questions like
*"what if I want to later be able to override the standard behaviour?"* and sometimes I start experimenting with new ideas,
which obviously takes more time. This happended to my with my simple recreation of ActiveRecord (and the Query classes).


[1]: https://www.statuspage.io
[2]: https://rvm.io/
