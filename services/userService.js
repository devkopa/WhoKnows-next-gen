import { userRepository } from "@/repositories/userRepository";
import bcrypt from "bcrypt";


export const userService = {

    async getUserId(usernameReq) {
        if(typeof usernameReq === "string") {
            try {
                const userId = await userRepository.getUserId(usernameReq);
                return userId?.id;
            } catch(error) {
                console.error("Service layer error for getting user id: " + error);
                return null;
            }
        }
    },

    async register(user) {

        try {
            const userId = await this.getUserId(user.username);
            if(userId != null) {
                throw new Error("The username is already taken");
            } else {
                const hashedPassword = await this.hashPassword(user.password);
                user.password = hashedPassword;
                return await userRepository.addUser(user);
            }

        } catch(error) {
            console.error("Service layer error for registration: " + error)
            throw error;
        }

    },

    async login(user) {
        try {
            const storedUser = await userRepository.getUserByUsername(user.username);
            
            if (!storedUser) {
                throw new Error("Wrong username.");
            }

            const passwordMatches = await this.passwordMatches(user.password,storedUser.password);

            if (!passwordMatches) {
                throw new Error("Wrong password.");
            }

            return {
                id: storedUser.id,
                username: storedUser.username,
                message: "Login successful",
            };
        } catch (error) {
            console.error("Service layer error for login: " + error.message);
            throw error;
        }
    },

    async logout(user) {
        const userId = await this.getUserId(user.username);
        
        if (!userId) {
            throw new Error("User not found.");
        }

        await userRepository.logout(userId);

        return {
            id: userId,
            username: user.username,
            message: "Logout successful",
        };
        
    },

    async passwordMatches(plainPassword, hashedPassword) {
        return bcrypt.compare(plainPassword, hashedPassword);
    },

    async hashPassword(password) {
        const saltRounds = 10;

        const hashedPassword = await bcrypt.hash(password, saltRounds);

        return hashedPassword;
    }
}