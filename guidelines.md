# General guidelines and principles on which this app is built
Some rough outlined rules and guidelines.
## Providers;
    - Providers may interact with each other by proxy
    - Providers may not decide whether and action is valid beyond it's own bounds - it is the callers job to decide this.
    - Should data be required for a method, coming from another provider:
      - 1. Attempt to handle the behaviour seperately
      - 2. Pass the data, if it is not crucial data for the other provider to function
      - 3. Pass the provider itself in a proxy.
### Drawing Context
    - The Drawing context is responsible for managing the different states of drawing, such as worldspace.
    - it should not manipulate the worldspace itself, but rather  call it's methods.
    - Handling files should be left to seperaate functions within draw_file
### Worldspace
    - handles the strokes in absolut position 
  
## File specs
    - Use json to encode data. 