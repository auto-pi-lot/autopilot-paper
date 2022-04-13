from autopilot.data.modeling.base import Data, Attributes
from pydantic import Field
from typing import Optional, Union
from datetime import datetime, timedelta

class Enclosure(Data):
    """
    Where does the subject live?
    """
    box:  Optional[Union[str, int]] = Field(
        default=None, 
        description="The box this Subject lives in"
    )
    room: Optional[Union[str, int]] = Field(
        default=None, 
        description="The room number that the animal is housed in"
    )

class Biography(Attributes):
    """
    Combined biographical information about an experimental subject
    """
    id:  str = Field(...,
        description="The indentifying name of this subject."
    )
    dob: datetime = Field(... ,
        description="The Subject's date of birth"
    )
    enclosure: Optional[Enclosure] = None

    @property
    def age(self) -> timedelta:
        """Difference between now and :attr:`.dob`"""
        return datetime.now() - self.dob