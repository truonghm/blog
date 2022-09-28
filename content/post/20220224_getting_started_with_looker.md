---
title: "Getting Started with Looker"
author: "truonghm"
date: '2022-02-24'
showToc: yes
TocOpen: no
draft: no
hidemeta: no
comments: no
disableHLJS: no
disableShare: no
hideSummary: yes
searchHidden: yes
ShowReadingTime: yes
ShowBreadCrumbs: yes
ShowPostNavLinks: yes
categories: "learning"
tags: ["looker", "bi"]
series: []
cover:
    image: "img/20220224_getting_started_with_looker/looker.jpg"
    responsiveImages: true
    # hidden: false
    relative: false
---

# Terms & Concepts

Below is a diagram that shows the relationships between concepts/functions of Looker. You can also see this flowchart as the journey of a Looker user, who starts by writing an SQL query, and ends with a dashboard.


{{< mermaid >}}
flowchart LR
    B(Views) -->|Model| C(Explore)
    subgraph data modelling
    direction LR
    A[DB table or SQL queries] --> B
    end
    subgraph visualization and analysis
    direction RL
    C --> D[Dashboards]
    C --> E[Looks]
    D --> E
    end
{{< /mermaid >}}

|  Concept   |                                                                   Description                                                                    |                                       Physical Entity in Looker                                       |    Creator    |     User      |       Equivalent in other BI tools        |           Layer           |
| :--------: | :----------------------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------: | :-----------: | :-----------: | :---------------------------------------: | :-----------------------: |
|   Views    |                                From a database table of SQL queries, we can create views (note the plural form).                                 |                                            .view.lkml file                                            |   Developer   |   Developer   |          Table/Query in Power BI          |         Modelling         |
|   Model    |                          Specifies the database to connect to and defines a collection of Explores for that connection.                          |                                           .model.lkml file                                            |   Developer   |   Developer   |             Unique to Looker              |         Modelling         |
|  Explore   | Not all views are useful for end users. From one or multiple joined views, we can define an explore. Joined views are defined using SQL dialect. | .model.lkml file, or a separate .explore.lkml file in case of derived tables or cleaner organization. |   Developer   | Business User |             Unique to Looker              |         Modelling         |
|   Looks    |                       A saved visualization created in the explore section. Can be used and shared in multiple dashboards.                       |                               Through GUI: Creating Looks or View Looks                               | Business User | Business User | A view in Tableau or a Visual in Power BI | Explore and Visualization |
| Dashboards |                       Collections of multiple looks. Dashboards can be interactive, i.e. use cross-filters and drill-down.                       |                        Through GUI: Creating Dashboards or Viewing Dashboards                         | Business User | Business User |  Report in Power BI, or story in Tableau  | Explore and Visualization |

# LookML project

A LookML project is the centralized space that define everything in the data modelling layer. Read the [documentation](https://cloud.google.com/looker/docs/what-is-lookml) for more information.

# Syntax

See the [Quick Reference](https://cloud.google.com/looker/docs/reference/lookml-quick-reference) documentation page.

# Other Useful Resources

- Youtube tutorials: [here](https://www.youtube.com/watch?v=3DPuLUcmAzyO8) and [here](https://www.youtube.com/watch?v=3Dc0qR1NIN16k)
- [Looker Connect](https://connect.looker.com/lesson)
- [Creating Dashboards on Looker](https://cloud.google.com/looker/docs/creating-user-defined-dashboards)
- [Viewing Dashboards on Looker](https://cloud.google.com/looker/docs/viewing-dashboards)
- [Saving and editing Looks on Looker](https://cloud.google.com/looker/docs/saving-and-editing-looks)
- [Viewing Looks on Looker](https://cloud.google.com/looker/docs/viewing-looks)