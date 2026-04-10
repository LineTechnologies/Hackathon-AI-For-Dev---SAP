# Sprint 4

This document traces the entire realization of sprint 2 and contains all the prompts used, results, and tips for this section. You can use this guide to create your own prompts based on your functional specifications.

> [!NOTE]
> For sprint 4, we are also basing ourselves on the specification document to introduce the new features and behaviors of the application. But, we will also make adjustments to refine our rendering, the rules, the business actions, etc. You will be able to understand how we can use Claude Code to perform very specific tasks and iterate on a particular "à la volé" rendering. In a project context, we could think of a scenario where a functional profile checks a first rendering of the application and asks you for adjustments.  

---

**Prompt 1 & 2 : Plan & Edit the project**

On the first two sprints, we perform the same operations as for the previous sprints in order to add a first wave of functionality.

![sprint4 preview1 iteration 2](images/sprint4_preview1_it2.png)



**Prompt 3 : Adjustments and Resolutions**
One can quickly notice that certain elements have not been completely taken into account. The charts do not work correctly. We will adjust these elements.

![sprint4 preview_2](images/sprint4_preview_2.png)

**Prompt 4 : Adjustments KIPs**
We can note that all the features around the KPIs are functional. But, we will sort things out a bit. In this part, we will iterate to adjust the UX and UI of these KPIs to have a more pleasant and relevant custom element.

![alt text](images/kpis.png)


**Prompt 4 : Adjustments Object Page**
Now, as before, we are going out of our functional specifications to adjust elements one by one. Here, we want to modify the Object Page:
- Add the blocking status to improve readability and use of business actions (block button, unlock and closure request)
- Adjust the graph
- Adjust the history table UI and its synchronization with the List Report

```txt
Perfect thank you, it works well. Now, we will adjust some elements on the Object Page.

Here are the tasks on the Object Page:
- Display the "Blocking Status" in the header of the object page after the "Risk Status"
- Graph Indicator: on the graph, I want to remove (make invisible) the "Show by" button that causes it to bug.
In Object Page: The "Stock history" table:
- Sort by decreasing date to have the most recent action first
- There is no "refresh" on the list report when performing a business action. I therefore want to have a synchronization between the business actions of the Object Page and the List Report: Blocking, Unlocking, and Request for closure. Thus, I want to see the "Blocking Status" update in the list report automatically, without needing to refresh manually (via the "go" button)

Can you adjust these elements please?
```

**Prompt 5 : Adjustments Business Actions**
We will adjust the business action rules and associated buttons to improve the UX of the application.
```txt
Act as an SAP CAP (Node.js) and Fiori Elements V4 expert.

We are resuming work on the 'Long Tail Vendor Management' application and making adjustments. We will work on the 'business actions' part, the buttons: block, unlock, and request for closure.

Adjustment tasks:
- When I perform a business action (e.g. blocked an active vendor), I would like its status to be updated in the interface of the object page and the list report. As it stands, this is not the case, I need to change the vendor in the list report, then return to the vendor to see the status update. I would like it to be automatic as soon as I change the status (do a refresh directly after the business action).
- Adjust the business action buttons in the object page according to the rules described below:

Rule business actions on the Object Page: 
Status "Blocked": 
- "Blocked" button not usable, one cannot block a vendor already blocked
- "Request for closure" button not usable, one cannot request a closure if already blocked
- Usable "Unlocked" button

Status "Request for closure": 
- Usable "Blocked" button
- Button "Request for closure" not usable, already in request for closure
- "Unlocked" button not usable

Status "Active": 
- Usable "Blocked" button
- Button "Request for closure" usable
- "Unlocked" button not usable

The "non-usable" indicates that the buttons must be hidden in the Object Page.

Can you make these adjustments please?
```

![Preview Application Sprint 4](images/preview_sprint4.png)

Now you can manually enhance the app and adjust the latest components, UX and UI of the app. You can also start again on a sprint 5, by modifying your specification and adjusting features, adding adjustments, etc.

You have the field of possibilities!

For example, we tested adding the multi-language system to have an application in French and English, allowing a unified interface in the same language.

![Final version](images/preview_final_version.png)

As part of this hands-on tutorial, we have finished the exercise, you can switch to hands-on tutorial 2 on Joule Studio or on the sharing part.

> Go to Hands-on Tutorial 2

---
 
*Guide version 1.0 — Adapted for LVMH Hackathon GenAI For Dev Workshops - SAP x Line | 2026*

*Author: Line*

<div align="left">
  <a href="https://www.line-technologies.com/">
    <img src="../../../../assets/images/Line_Logo_Version claire_V1.png" height="70" alt="Logo Line" />
  </a>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="https://www.sap.com">
  <img src="../../../../assets/images/SAP_2011_logo.svg.png" height="70" alt="Logo SAP" />
  </a>
</div>