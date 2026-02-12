#ifndef QUAT_NORM_HPP
#define QUAT_NORM_HPP

struct QuatResult {
    float q_out[4];     // Normalized quaternion [w, x, y, z]
    float magnitude;    // Original magnitude
    bool valid;         // True if normalization successful
};

class QuatNorm {
public:
    QuatNorm() = default;
    ~QuatNorm() = default;
    
    // Normalize a quaternion and return result with magnitude
    QuatResult normalize(const float q[4]);
};

#endif // QUAT_NORM_HPP