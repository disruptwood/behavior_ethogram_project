 This project creates ethograms – visual charts that show behaviors of flies over time.
 It works for both single flies and groups of flies.
 The behaviors are shown as colored bars (patches) for easy viewing.

 Why Patches and Not Lines?
 I use patches instead of lines because they are more flexible and efficient for drawing behaviors.
 Patches let me fill entire time intervals with color and transparency,
 making the ethogram cleaner and faster to draw.

 How to Use This Project
 1. Run the GUI:
    - Open MATLAB.
    - Run `gui_main.m` from the scripts folder.
    - Choose the behavior score files (`scores_.mat`).
    - Pick one of the following ethogram types:
      - Single Fly Ethogram: For one fly’s behaviors.
      - Color Single Fly Ethogram: A color-based ethogram for a single fly.
      - Heatmap Single Fly Ethogram: Displays behaviors of a single fly as a heatmap.
      - Group Ethogram: For a group of flies (behaviors combined).

 2. View Results:
    - Single Fly: Each behavior is shown as a row of colored bars.
    - Color Single Fly: A color-coded ethogram representing behavior intensities.
    - Heatmap Single Fly: Behaviors are visualized using heatmap intensity.
    - Group Ethogram: Behaviors appear with transparency based on how many flies exhibited that behavior.

 What Each Code File Does

  `create_single_ethogram.m`  
    Draws the ethogram for one fly. It takes the start and end times of behaviors and plots them as colored patches. Behavior names appear neatly aligned on the left.

  `create_group_ethogram.m`  
    Creates the group ethogram by combining data from multiple flies. Transparency shows how often a behavior happens across all flies. Uses the same style as the single ethogram.

  `plot_behavior_patches.m`  
    A helper function that actually draws the colored patches. Both single and group ethogram files use this to avoid repeating the same code.

  `heatmap_single_ethogram.m`  
    Creates a heatmap ethogram for a single fly, displaying behavior intensity over time as a heatmap.

  `color_single_ethogram.m`  
    Generates a color-coded ethogram for a single fly, where colors reflect the behaviors in a compact format.

  `extract_behavior_data.m`  
    Extracts behavior start and end times for a specific fly.

  `extract_behavior_data_group.m`  
    Extracts data for a group of flies. This is used to build the group ethogram.

  `extractFilesAndLabels.m`  
    Loads the behavior score files and cleans up the behavior names (like removing extra underscores).

  `add_project_paths.m`  
    Adds all necessary folders (like `functions/`) to the MATLAB path so everything runs smoothly.

 Where’s What?
  `data/` – Place your input behavior files (`scores_.mat`) here.  
  `functions/` – Reusable code files for extracting and plotting data.  
  `results/` – Save your ethograms here.  
  `scripts/` – Main scripts to run the project, like `gui_main.m`.  

 I know I didn't have to do a whole project, but I got a little stuck and did. It's hard not to finish things before the end.

 That’s It!
 Run the GUI, load your files, and create beautiful ethograms – no headaches. Patches and heatmaps make everything look cleaner and faster. Simple, right?
