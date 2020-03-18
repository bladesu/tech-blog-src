---
title: "<____________ Contents (Read Me) ____________>"
date: 2020-03-06T23:33:27+08:00
draft: true
---

Here I will continously update some contents about sytanx in __GNU make__ which is uncommon I think or ones is not eaily understood by intuition. If you have interesting about that, you will gain big benefit from reading the document([https://www.gnu.org/software/make/manual/make.html](https://www.gnu.org/software/make/manual/make.html)).

## Automatic Variables

The __Automatic variables__ feature of __GUN make__ allow you have variable whose value computed afresh for each rule that is executed in the runtime. 

#### [$@ and $< pair]({{< ref "/learning/building_tool/gnu_make/unusual_syntax/auto_var_1.md" >}})

***

## Static Pattern Rules

Cited from documentation(4.12):
>Static pattern rules are rules which specify multiple targets and construct the prerequisite names for each target based on the target name. They are more general than ordinary rules with multiple targets because the targets do not have to have identical prerequisites. Their prerequisites must be analogous, but not necessarily identical.

#### [Syntax of Static Pattern Rules]({{< ref "/learning/building_tool/gnu_make/unusual_syntax/static_pattern_rules.md" >}})
```markdown
targets …: target-pattern: prereq-patterns …
        recipe
        …
```


