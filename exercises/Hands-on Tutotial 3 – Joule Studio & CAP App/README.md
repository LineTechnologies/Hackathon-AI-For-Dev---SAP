# Hands-on Tutorial 3 - Joule Studio & CAP App

## Introduction

During the Hackathon, you were able to create a CAP Fiori application, agents, skills, explore Joule Studio, the AI agents.

Through this third hands-on tutorial, you will adjust and refine everything while trying to integrate the two works together.

## Objectives
- Switch from mock data to real S/4HANA data using BTP destionation 
- Understand how to merge a Joule Agents and Skills with CAP/Fiori application
- Explore and reseach about posibilities and use case on merging this 2 activities

## Steps

## 1. Switch from mock data to real S/4HANA data using BTP destination 
Through the first hands-on tutorial, we created a functional CAP application based on our functional specifications. However, this one uses mock data, which is very good for a first version expressing our needs. But we must now "connect" it to our S/4HANA.

![StoryBoard](images/storyboard.png)

The idea now is to avoid using these test data to connect your application to an S/4HANA system and understand this implementation. In this step-by-step tutorial, we will set up a connection to 3 sandbox.

**0. Create a new branch**

We start by creating a new branch "feature". This allow you to don't destroy your current project if something goes wrong. We could remove this branch without losing all your project and progress and without having to raise several commits.

```bash
$ git branch feature
$ git checkout feature
```

**1. Get the edmx file**

**2. Import API with CAP**

**3. Adapt data models (shema.cds & service.cds)**

**4. Write the interception logic (service.js)**

![Final Result](image-2.png)

> You can find [a detailed guide on this integration](documentations/integration-guide-s4hana.md).

## 2. Add Joule on the CAP application 


## Try to trigger the aggent using prompts


