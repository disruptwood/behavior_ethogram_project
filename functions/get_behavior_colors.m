function [behaviorColorMap, fallbackColor] = get_behavior_colors()
% GET_BEHAVIOR_COLORS:
%   Returns a containers.Map of behavior names -> RGB color,
%   plus a fallback color to use if a behavior isn’t in the map.

    behaviorColorMap = containers.Map( ...
        {'Walk', 'Stop', 'Turn', 'Long_Distance_Approach', 'Touch', ...
         'Long_Lasting_Interaction', 'Short_Distance_Approach', ...
         'Social_Clustering', 'Grooming'}, ...
        { [0.00, 0.50, 0.00], ...         % Walk - Green
          [1.00, 0.00, 0.00], ...         % Stop - Red
          [0.1255, 0.6980, 0.6667], ...   % Turn - Light Sea Green
          [0.00, 0.00, 0.8039], ...       % Long_Distance_Approach - Medium Blue
          [0.5451, 0.00, 0.5451], ...     % Touch - Dark Magenta
          [0.9569, 0.6431, 0.3765], ...   % Long_Lasting_Interaction - Sandy Brown
          [0.6980, 0.1333, 0.1333], ...   % Short_Distance_Approach - Firebrick
          [0.8588, 0.4392, 0.5765], ...   % Social_Clustering - Pale Violet Red
          [0.70,  0.70,  0.70] }); ...    % Grooming - Gray

    % You can pick any fallback color you like (e.g., goldenrod-like).
    fallbackColor = [0.75, 0.75, 0.25]; 
end