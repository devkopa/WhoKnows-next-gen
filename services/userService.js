import { userRepository } from "@/repositories/userRepository";
import { bcrypt } from "bcrypt";


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


    // Security functions

    async hashPassword(password) {
        const saltRounds = 10;

        const hashedPassword = await bcrypt.hash(password, saltRounds);

        return hashedPassword;

    }

}