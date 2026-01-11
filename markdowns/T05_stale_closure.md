# Stale Closure

Stale closures occur when a function captures variables from its surrounding scope, but those variables change after the function is created. This can lead to unexpected behavior if the function is called later and uses the updated values instead of the original ones.

I compare the counter app in React and Flutter to illustrate this concept.
