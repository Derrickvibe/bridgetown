Feature: frontmatter defaults
  Scenario: Use default for frontmatter variables internally
    Given I have a _layouts directory
    And I have a pretty layout that contains "THIS IS THE LAYOUT: {{content}}"

    And I have a _posts directory
    And I have the following post:
      | title             | date       | content          |
      | default layout    | 2013-09-11 | just some post   |
    And I have an "index.html" page with title "some title" that contains "just some page"

    And I have a configuration file with "defaults" set to "[{scope: {path: ""}, values: {layout: "pretty"}}]"

    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "THIS IS THE LAYOUT: <p>just some post</p>" in "output/2013/09/11/default-layout.html"
    And I should see "THIS IS THE LAYOUT: just some page" in "output/index.html"

  Scenario: Use default for frontmatter variables in Liquid
    Given I have a _posts directory
    And I have the following post:
      | title        | date       | content                                          |
      | default data | 2013-09-11 | <p>{{page.custom}}</p><div>{{page.author}}</div> |
    And I have an "index.html" page that contains "just {{page.custom}} by {{page.author}}"
    And I have a configuration file with "defaults" set to "[{scope: {path: ""}, values: {custom: "some special data", author: "Ben"}}]"
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "<p>some special data</p>\n<div>Ben</div>" in "output/2013/09/11/default-data.html"
    And I should see "just some special data by Ben" in "output/index.html"

  Scenario: Override frontmatter defaults by path
    Given I have a _layouts directory
    And I have a root layout that contains "root: {{ content }}"
    And I have a subfolder layout that contains "subfolder: {{ content }}"

    And I have a _posts directory
    And I have the following post:
      | title | date       | content                      |
      | about | 2013-10-14 | info on {{page.description}} |

    And I have an "index.html" page with title "overview" that contains "Overview for {{page.description}}"
    And I have a special directory
    And I have an "special/index.html" page with title "section overview" that contains "Overview for {{page.description}}"

    And I have a configuration file with "defaults" set to "[{scope: {path: "special"}, values: {layout: "subfolder", description: "the special section"}}, {scope: {path: ""}, values: {layout: "root", description: "the webpage"}}]"

    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "root: <p>info on the webpage</p>" in "output/2013/10/14/about.html"
    And I should see "root: Overview for the webpage" in "output/index.html"
    And I should see "subfolder: Overview for the special section" in "output/special/index.html"

  Scenario: Use frontmatter variables by relative path
    Given I have a _layouts directory
    And I have a main layout that contains "main: {{ content }}"

    And I have a _posts directory
    And I have the following post:
      | title | date       | content                               |
      | about | 2013-10-14 | content of site/2013/10/14/about.html |
    And I have a special/_posts directory
    And I have the following post in "special":
      | title  | date       | path  | content                                |
      | about1 | 2013-10-14 | local | content of site/2013/10/14/about1.html |
      | about2 | 2013-10-14 | local | content of site/2013/10/14/about2.html |

    And I have a configuration file with "defaults" set to "[{scope: {path: "special"}, values: {layout: "main"}}, {scope: {path: "special/_posts"}, values: {layout: "main"}}, {scope: {path: "_posts"}, values: {layout: "main"}}]"

    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "main: <p>content of site/2013/10/14/about.html</p>" in "output/2013/10/14/about.html"
    And I should see "main: <p>content of site/2013/10/14/about1.html</p>" in "output/2013/10/14/about1.html"
    And I should see "main: <p>content of site/2013/10/14/about2.html</p>" in "output/2013/10/14/about2.html"

  Scenario: Use frontmatter scopes for subdirectories
    Given I have a _layouts directory
    And I have a main layout that contains "main: {{ content }}"

    And I have a _posts/en directory
    And I have the following post under "en":
      | title | date       | content                               |
      | helloworld | 2014-09-01 | {{page.lang}} is the current language |
    And I have a _posts/de directory
    And I have the following post under "de":
      | title  | date       | content                                        |
      | hallowelt | 2014-09-01 | {{page.lang}} is the current language |

    And I have a configuration file with "defaults" set to "[{scope: {path: "_posts/en"}, values: {layout: "main", lang: "en"}}, {scope: {path: "_posts/de"}, values: {layout: "main", lang: "de"}}]"

    When I run bridgetown build
    Then the output directory should exist
    And I should see "main: <p>en is the current language</p>" in "output/2014/09/01/helloworld.html"
    And I should see "main: <p>de is the current language</p>" in "output/2014/09/01/hallowelt.html"

  Scenario: Override frontmatter defaults by type
    Given I have a _posts directory
    And I have the following post:
      | title          | date       | content |
      | this is a post | 2013-10-14 | blabla  |
    And I have an "index.html" page that contains "interesting stuff"
    And I have a configuration file with "defaults" set to "[{scope: {path: "", type: "post"}, values: {permalink: "/post.html"}}, {scope: {path: "", type: "page"}, values: {permalink: "/page.html"}}, {scope: {path: ""}, values: {permalink: "/perma.html"}}]"
    When I run bridgetown build
    Then I should see "blabla" in "output/post.html"
    And I should see "interesting stuff" in "output/page.html"
    But the "output/perma.html" file should not exist

  Scenario: Actual frontmatter overrides defaults
    Given I have a _posts directory
    And I have the following post:
      | title    | date       | permalink         | author   | content                   |
      | override | 2013-10-14 | /frontmatter.html | some guy | a blog by {{page.author}} |
    And I have an "index.html" page with permalink "override.html" that contains "nothing"
    And I have a configuration file with "defaults" set to "[{scope: {path: ""}, values: {permalink: "/perma.html", author: "Chris"}}]"
    When I run bridgetown build
    Then I should see "a blog by some guy" in "output/frontmatter.html"
    And I should see "nothing" in "output/override.html"
    But the "output/perma.html" file should not exist

  Scenario: Define permalink default for posts
    Given I have a _posts directory
    And I have the following post:
      | title          | date       | category | content |
      | testpost       | 2013-10-14 | blog     | blabla  |
    And I have a configuration file with "defaults" set to "[{scope: {path: "", type: "posts"}, values: {permalink: "/:categories/:title/"}}]"
    When I run bridgetown build
    Then I should see "blabla" in "output/blog/testpost/index.html"

  Scenario: Use frontmatter defaults in collections
    Given I have a _slides directory
    And I have a "index.html" file that contains "nothing"
    And I have a "_slides/slide1.html" file with content:
    """
    ---
    ---
    Value: {{ page.myval }}
    """
    And I have a "_config.yml" file with content:
    """
      collections:
        slides:
          output: true
      defaults:
        -
          scope:
            path: ""
            type: slides
          values:
            myval: "Test"
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Value: Test" in "output/slides/slide1.html"

  Scenario: Override frontmatter defaults inside a collection
    Given I have a _slides directory
    And I have a "index.html" file that contains "nothing"
    And I have a "_slides/slide2.html" file with content:
    """
    ---
    myval: Override
    ---
    Value: {{ page.myval }}
    """
    And I have a "_config.yml" file with content:
    """
      collections:
        slides:
          output: true
      defaults:
        -
          scope:
            path: ""
            type: slides
          values:
            myval: "Test"
    """
    When I run bridgetown build
    Then I should get a zero exit status
    And the output directory should exist
    And I should see "Value: Override" in "output/slides/slide2.html"

  Scenario: Deep merge frontmatter defaults
    Given I have an "index.html" page with fruit "{orange: 1}" that contains "Fruits: {{ page.fruit.orange | plus: page.fruit.apple }}"
    And I have a configuration file with "defaults" set to "[{scope: {path: ""}, values: {fruit: {apple: 2}}}]"
    When I run bridgetown build
    Then I should see "Fruits: 3" in "output/index.html"
