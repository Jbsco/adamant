#include "quat_norm.hpp"
#include <cmath>

QuatResult QuatNorm::normalize(const float q[4]) {
    QuatResult result;
    
    // Calculate magnitude: sqrt(w^2 + x^2 + y^2 + z^2)
    result.magnitude = std::sqrt(q[0]*q[0] + q[1]*q[1] + q[2]*q[2] + q[3]*q[3]);
    
    // Check for zero magnitude (invalid quaternion)
    const float epsilon = 1e-12f;
    if (result.magnitude < epsilon) {
        result.valid = false;
        // Set output to identity quaternion as safe fallback
        result.q_out[0] = 1.0f;  // w
        result.q_out[1] = 0.0f;  // x  
        result.q_out[2] = 0.0f;  // y
        result.q_out[3] = 0.0f;  // z
        return result;
    }
    
    // Normalize by dividing by magnitude
    result.valid = true;
    result.q_out[0] = q[0] / result.magnitude;
    result.q_out[1] = q[1] / result.magnitude;  
    result.q_out[2] = q[2] / result.magnitude;
    result.q_out[3] = q[3] / result.magnitude;
    
    return result;
}